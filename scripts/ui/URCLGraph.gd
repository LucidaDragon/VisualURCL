class_name URCLGraph
extends GraphEdit

enum CONST_PIN_TYPES { none, integer, label, port }
enum PIN_TYPES { none, execution, integer, boolean }

static func get_pin_colors() -> Array[Color]: return [
	Color.MAGENTA,
	Color.WHITE,
	Color.AQUAMARINE,
	Color.FIREBRICK
]

static func get_category_colors() -> Dictionary: return {
	"": contrast_correction(Color.DIM_GRAY, 0.3),
	"Variables": contrast_correction(Color.DARK_GREEN, 0.3),
	"Integer": contrast_correction(Color.AQUAMARINE, 0.3),
	"Basic": contrast_correction(Color.CORNFLOWER_BLUE, 0.3),
	"Ports": contrast_correction(Color.PURPLE, 0.3),
	"Boolean": contrast_correction(Color.FIREBRICK, 0.3),
	"Memory": contrast_correction(Color.GOLDENROD, 0.3)
}

static func contrast_correction(color: Color, brightness: float) -> Color:
	return Color.from_hsv(color.h, color.s, brightness)

var node_templates: Array[URCLGraphNode] = []

@onready var code_splitter: HSplitContainer = $"../.."
@onready var property_splitter: HSplitContainer = $".."
@onready var code_box: CodeEdit = $"../../CodeEdit"
@onready var node_menu: NodeMenu = $"../../../Popups/NodeMenu"
@onready var emulator: Window = $"../../../Popups/Emulator"
var control_buttons: int = 0
var pan_speed: float = 1000
var instructions_per_tick: int = 1
var toolbar: HBoxContainer = get_zoom_hbox()
var code_button: Button = Button.new()
var run_button: Button = Button.new()
var tps_label: Label = Label.new()
var tps_update_cooldown: float = 0.0
var code_machine: URCLMachine = URCLMachine.new()
var code_update_cooldown: float = -1.0
var selected_nodes: Array[GraphNode] = []
var variables: Array[Variable] = []
var next_label: int = 0

func _init():
	code_machine.suspend()
	_init_buttons()
	connect("node_selected", func(node):
		if node is GraphNode: selected_nodes.append(node)
	)
	connect("node_deselected", func(node):
		if node is GraphNode: selected_nodes.erase(node)
	)
	connect("connection_drag_started", func(node_name, port, is_output):
		var node = get_node_by_name(node_name)
		if get_port_type(node, port, is_output) == PIN_TYPES.execution:
			if is_output: remove_connections_to_port(node, port, is_output)
		else:
			if not is_output: remove_connections_to_port(node, port, is_output)
	)
	connect("connection_request", func(from_node, from_port, to_node, to_port):
		var from: GraphNode = get_node_by_name(from_node)
		var to: GraphNode = get_node_by_name(to_node)
		if from.get_connection_output_type(from_port) == to.get_connection_input_type(to_port):
			if get_port_type(from, from_port, true) == PIN_TYPES.execution:
				remove_connections_to_port(from, from_port, true)
			else:
				remove_connections_to_port(to, to_port, false)
			
			connect_node(from_node, from_port, to_node, to_port)
			for node in get_children():
				if node is URCLGraphNode and node_has_loops(node):
					disconnect_node(from_node, from_port, to_node, to_port)
					break
			queue_codegen()
	)
	connect("gui_input", func(event):
		if event is InputEventKey and event.pressed and event.keycode == KEY_DELETE:
			while len(selected_nodes) > 0:
				delete_node(selected_nodes.pop_back())
	)

func _ready():
	_init_nodes()
	node_menu.connect("ready", Callable(self, "_init_node_menu"))

func _init_buttons() -> void:
	code_button.flat = true
	code_button.icon = preload("res://icons/code.svg")
	code_button.tooltip_text = "Show code."
	code_button.focus_mode = Control.FOCUS_NONE
	code_button.connect("pressed", Callable(self, "toggle_code"))
	
	run_button.flat = true
	run_button.icon = preload("res://icons/run.svg")
	run_button.tooltip_text = "Run program or main function."
	run_button.focus_mode = Control.FOCUS_NONE
	run_button.connect("pressed", Callable(self, "run_code"))
	
	toolbar.add_child(code_button)
	toolbar.add_child(run_button)
	toolbar.add_child(tps_label)

func _init_nodes() -> void:
	const path = "res://nodes/"
	var directory = DirAccess.open(path)
	directory.list_dir_begin()
	var file = directory.get_next()
	while file != "":
		if file.ends_with(".tscn.remap"): file = file.substr(0, len(file) - 6)
		if not directory.current_is_dir() and file.ends_with(".tscn"):
			var node: URCLGraphNode = load(path + file).instantiate()
			node.apply_style()
			node_templates.append(node)
		file = directory.get_next()
	for input in emulator.get_input_ports():
		var node = InPortNode.new()
		node.set_target_port(input)
		node.apply_style()
		node_templates.append(node)
	for output in emulator.get_output_ports():
		var node = OutPortNode.new()
		node.set_target_port(output)
		node.apply_style()
		node_templates.append(node)

func _init_node_menu() -> void:
	connect("popup_request", func(pos):
		node_menu.show_menu_at(get_global_rect().position + pos)
	)
	for template in node_templates:
		node_menu.add_node(template).connect("pressed", func():
			add_node(template, true)
		)

func _input(event):
	if event is InputEventKey:
		var mask: int = 0
		if event.keycode == KEY_UP: mask = 1
		elif event.keycode == KEY_DOWN: mask = 2
		elif event.keycode == KEY_RIGHT: mask = 4
		elif event.keycode == KEY_LEFT: mask = 8
		if event.pressed and Input.is_key_pressed(KEY_CTRL): control_buttons |= mask
		else: control_buttons &= ~mask

func _process(delta):
	if control_buttons != 0:
		var direction = ((Vector2(0, -1) if control_buttons & 1 else Vector2.ZERO) + (Vector2(0, 1) if control_buttons & 2 else Vector2.ZERO) + (Vector2(1, 0) if control_buttons & 4 else Vector2.ZERO) + (Vector2(-1, 0) if control_buttons & 8 else Vector2.ZERO)).normalized()
		scroll_offset += direction * pan_speed * zoom * delta
	
	if code_update_cooldown > 0.0:
		code_update_cooldown = max(0.0, code_update_cooldown - delta)
		if code_update_cooldown == 0.0: _update_code()
	
	tps_label.visible = not code_machine.suspended
	tps_update_cooldown = max(0.0, tps_update_cooldown - delta)
	if tps_update_cooldown == 0.0:
		tps_label.text = str(round((instructions_per_tick * delta) * 100) / 100.0) + " tps"
		tps_update_cooldown = 5.0
	
	if not code_machine.suspended:
		if delta > 0.16 and instructions_per_tick > 1: instructions_per_tick -= 1
		elif delta < 0.16: instructions_per_tick += 1
	
		for _i in range(instructions_per_tick): code_machine.step()

func _update_code() -> void:
	code_machine = URCLMachine.new()
	emulator.bind_drivers(code_machine)
	reset_labels()
	for node in get_children(): node.update_labels()
	for node in get_children():
		if node is FunctionNode:
			code_machine.instructions += node.get_all_code(len(variables) + 1)
	code_machine.validate()
	code_box.text = code_machine.get_string()
	for error in code_machine.errors:
		print(error.message)

func queue_codegen() -> void:
	code_update_cooldown = 3.0

func get_node_by_name(node_name: StringName) -> GraphNode: return get_node(NodePath(node_name))

func get_port_type(node: GraphNode, port: int, is_output: bool) -> int:
	if is_output: return node.get_connection_output_type(port)
	else: return node.get_connection_input_type(port)

func node_has_loops(node: URCLGraphNode) -> bool:
	if node == null: return false
	var origin = node
	var visited: Array[URCLGraphNode] = [node]
	var queue: Array[URCLGraphNode] = node.get_branches()
	while true:
		node = null
		while node == null and len(queue) > 0: node = queue.pop_front()
		if node == null: break
		elif node == origin: return true
		elif not node in visited:
			visited.append(node)
			queue.append_array(node.get_branches())
	return false

func remove_connections_to_port(node: GraphNode, port: int, is_output: bool) -> void:
	for connection in get_connection_list():
		if (connection.to == node.name and connection.to_port == port and not is_output) or (connection.from == node.name and connection.from_port == port and is_output):
			disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
	queue_codegen()

func remove_connections_to_node(node: GraphNode) -> void:
	for connection in get_connection_list():
		if connection.to == node.name or connection.from == node.name:
			disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
	queue_codegen()

func delete_node(node: GraphNode) -> void:
	remove_connections_to_node(node)
	selected_nodes.erase(node)
	remove_child(node)
	queue_codegen()

func toggle_code() -> void:
	code_splitter.collapsed = !code_splitter.collapsed
	code_splitter.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED if code_splitter.collapsed else SplitContainer.DRAGGER_VISIBLE

func run_code() -> void:
	code_update_cooldown = 0.0
	_update_code()
	emulator.show()
	code_machine.execute(code_machine.get_label("main") if code_machine.has_label("main") else 0)

func create_variable() -> Variable:
	var variable = Variable.new()
	variable.owner = self
	variable.make_unique()
	node_menu.add_variable(variable)
	variables.append(variable)
	variable.connect("deleted", func():
		variables.erase(variable)
	)
	return variable

func get_variable_by_name(variable_name: String) -> Variable:
	for variable in variables:
		if variable.name == variable_name: return variable
	return null

func get_variable_index(variable: Variable) -> int:
	return variables.find(variable)

func create_label() -> URCLLabel:
	var label = URCLLabel.create("__l" + str(next_label))
	next_label += 1
	return label

func reset_labels() -> void:
	next_label = 0

func add_node(template: URCLGraphNode, at_node_menu: bool, direct: bool = false) -> GraphNode:
	var node = template if direct else template.duplicate()
	node.refresh_pins()
	if at_node_menu:
		node.position_offset = (node_menu.position + scroll_offset) / zoom
	add_child(node)
	if node is FunctionNode: node_menu.add_function(node)
	queue_codegen()
	return node
