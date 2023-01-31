class_name NodeCategory
extends VBoxContainer

var text: String: get = _get_text, set = _set_text

@onready var button: Button = $Button
@onready var margin: MarginContainer = $Margin
@onready var arrangement: VBoxContainer = $Margin/Nodes

var open_icon = preload("res://icons/category_open.svg")
var closed_icon = preload("res://icons/category_closed.svg")

func _get_text() -> String: return str(name)
func _set_text(value: String) -> void:
	name = value
	if button != null: button.text = value

func _ready():
	button.text = name
	button.icon = closed_icon
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.connect("toggled", Callable(self, "_toggle_open"))
	
	margin.visible = false
	margin.add_theme_constant_override("margin_left", 20)
	
	arrangement.connect("sort_children", func():
		var children = arrangement.get_children()
		children.sort_custom(func(a, b):
			return a.text < b.text
		)
		for i in range(len(children)):
			arrangement.move_child(children[i], i)
	)

func _toggle_open(state: bool) -> void:
	margin.visible = state
	button.icon = open_icon if state else closed_icon

func add_node(template: URCLGraphNode) -> Button:
	var child_button = Button.new()
	child_button.name = template.title
	child_button.text = template.title
	child_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	arrangement.add_child(child_button)
	
	queue_sort()
	
	return child_button

func add_function(func_node: FunctionNode) -> Button:
	var graph: URCLGraph = func_node.get_parent()
	var child_button = Button.new()
	child_button.name = func_node.get_caller_title()
	child_button.text = func_node.get_caller_title()
	child_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	child_button.connect("pressed", func():
		var call_node = CallNode.new()
		call_node.set_source(func_node)
		call_node.apply_style()
		graph.add_node(call_node, true, true)
		child_button.release_focus()
	)
	func_node.connect("function_renamed", func():
		child_button.name = func_node.get_caller_title()
		child_button.text = func_node.get_caller_title()
	)
	func_node.connect("tree_exiting", Callable(child_button, "queue_free"))
	
	arrangement.add_child(child_button)
	
	return child_button

func add_variable(variable: Variable) -> Array[Button]:
	var get_button = Button.new()
	get_button.name = variable.title_get
	get_button.text = variable.title_get
	get_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	get_button.connect("pressed", func():
		variable.add_get_node()
		get_button.release_focus()
	)
	arrangement.add_child(get_button)
	
	var set_button = Button.new()
	set_button.name = variable.title_set
	set_button.text = variable.title_set
	set_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	set_button.connect("pressed", func():
		variable.add_set_node()
		set_button.release_focus()
	)
	arrangement.add_child(set_button)
	
	variable.connect("renamed", func():
		get_button.name = variable.title_get
		get_button.text = variable.title_get
		set_button.name = variable.title_set
		set_button.text = variable.title_set
	)
	variable.connect("deleted", func():
		get_button.queue_free()
		set_button.queue_free()
	)
	
	queue_sort()
	
	return [get_button, set_button]

func clear_filter() -> void:
	visible = true
	if button.button_pressed: button.button_pressed = false
	for child_button in arrangement.get_children():
		if child_button is Button:
			child_button.visible = true

func apply_filter(contains: String) -> void:
	contains = contains.to_upper()
	var any_matches: bool = false
	for child_button in arrangement.get_children():
		if child_button is Button:
			child_button.visible = child_button.name.to_upper().contains(contains)
			if child_button.visible: any_matches = true
	button.button_pressed = any_matches
	visible = any_matches
