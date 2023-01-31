class_name URCLGraphNode
extends GraphNode

@export var category: String
@export var pin_inputs: Array[String]
@export var pin_outputs: Array[String]

var _style_applied: bool = false

func apply_style() -> void:
	if _style_applied: return
	var base_style: StyleBoxFlat = get_theme_stylebox("frame").duplicate()
	var selected_style: StyleBoxFlat = base_style.duplicate()
	var category_colors: Dictionary = URCLGraph.get_category_colors()
	var color = category_colors[category] if category in category_colors else category_colors[""]
	base_style.border_color = color
	selected_style.border_color = color.lightened(0.3)
	add_theme_stylebox_override("frame", base_style)
	add_theme_stylebox_override("selected_frame", selected_style)
	_style_applied = true

func refresh_pins() -> void:
	for i in range(max(len(pin_inputs), len(pin_outputs))):
		var has_left = i < len(pin_inputs)
		var has_right = i < len(pin_outputs)
		
		var left_name = pin_inputs[i] if has_left else ""
		var right_name = pin_outputs[i] if has_right else ""
		
		var left_constant: URCLGraph.CONST_PIN_TYPES = URCLGraph.CONST_PIN_TYPES.none
		var left_type: URCLGraph.PIN_TYPES = URCLGraph.PIN_TYPES.integer if has_left else URCLGraph.PIN_TYPES.none
		if left_name.begins_with("exec_"):
			left_name = left_name.substr(5)
			left_type = URCLGraph.PIN_TYPES.execution
		elif left_name.begins_with("bool_"):
			left_name = left_name.substr(5)
			left_type = URCLGraph.PIN_TYPES.boolean
		elif left_name.begins_with("const_"):
			left_name = left_name.substr(6)
			left_type = URCLGraph.PIN_TYPES.none
			left_constant = URCLGraph.CONST_PIN_TYPES.integer
		elif left_name.begins_with("label_"):
			left_name = left_name.substr(6)
			left_type = URCLGraph.PIN_TYPES.none
			left_constant = URCLGraph.CONST_PIN_TYPES.label
		elif left_name.begins_with("port_"):
			left_name = left_name.substr(5)
			left_type = URCLGraph.PIN_TYPES.none
			left_constant = URCLGraph.CONST_PIN_TYPES.port
		
		var right_type: URCLGraph.PIN_TYPES = URCLGraph.PIN_TYPES.integer if has_right else URCLGraph.PIN_TYPES.none
		if right_name.begins_with("exec_"):
			right_name = right_name.substr(5)
			right_type = URCLGraph.PIN_TYPES.execution
		elif right_name.begins_with("bool_"):
			right_name = right_name.substr(5)
			right_type = URCLGraph.PIN_TYPES.boolean
		
		var colors = URCLGraph.get_pin_colors()
		var left_color = colors[left_type]
		var right_color = colors[right_type]
		
		var left_label = Label.new()
		left_label.text = left_name
		
		var right_label = Label.new()
		right_label.text = right_name
		
		var spacer = Control.new()
		spacer.size_flags_horizontal = SIZE_EXPAND_FILL
		spacer.size_flags_vertical = SIZE_EXPAND_FILL
		
		var label_box = HBoxContainer.new()
		label_box.add_child(left_label)
		if left_constant == URCLGraph.CONST_PIN_TYPES.integer:
			var value_entry = SpinBox.new()
			value_entry.select_all_on_focus = true
			value_entry.size_flags_horizontal = SIZE_EXPAND_FILL
			value_entry.max_value = 0xFFFFFFFF
			value_entry.min_value = 0
			value_entry.custom_minimum_size = Vector2(100.0, 0.0)
			value_entry.connect("value_changed", func(_value):
				get_parent().queue_codegen()
			)
			label_box.add_child(value_entry)
		elif left_constant == URCLGraph.CONST_PIN_TYPES.label or left_constant == URCLGraph.CONST_PIN_TYPES.port:
			var text_entry = LineEdit.new()
			text_entry.placeholder_text = "Name" if left_constant == URCLGraph.CONST_PIN_TYPES.label else "Port"
			text_entry.custom_minimum_size = Vector2(100.0, 0.0)
			text_entry.connect("text_changed", func(_text):
				get_parent().queue_codegen()
			)
			label_box.add_child(text_entry)
		label_box.add_child(spacer)
		label_box.add_child(right_label)
		
		add_child(label_box)
		set_slot(i, left_type != URCLGraph.PIN_TYPES.none, left_type, left_color, right_type != URCLGraph.PIN_TYPES.none, right_type, right_color)

func get_constant_inputs() -> Array[Control]:
	var result: Array[Control] = []
	for row in get_children():
		if row is HBoxContainer:
			for control in row.get_children():
				if control is SpinBox: result.append(control)
				elif control is LineEdit: result.append(control)
	return result

func get_input_nodes() -> Array[URCLGraphNode]:
	var result: Array[URCLGraphNode] = []
	result.resize(get_connection_input_count())
	var graph: URCLGraph = get_parent()
	for connection in graph.get_connection_list():
		if graph.get_node_by_name(connection.to) == self:
			result[connection.to_port] = graph.get_node_by_name(connection.from)
	return result

func get_output_nodes() -> Array[URCLGraphNode]:
	var result: Array[URCLGraphNode] = []
	result.resize(get_connection_output_count())
	var graph: URCLGraph = get_parent()
	for connection in graph.get_connection_list():
		if graph.get_node_by_name(connection.from) == self:
			result[connection.from_port] = graph.get_node_by_name(connection.to)
	return result

func create_new_label() -> URCLLabel:
	return get_parent().create_label()

func update_labels() -> void:
	return

func get_code(_base_register: int = 1, _depth: int = 0) -> Array[URCLInstruction]:
	return []

func get_next_node() -> URCLGraphNode:
	return null

func get_branches() -> Array[URCLGraphNode]:
	return [get_next_node()]

func get_all_code(base_register: int = 1, depth: int = 0) -> Array[URCLInstruction]:
	var result: Array[URCLInstruction] = get_code(base_register, depth)
	var next = get_next_node()
	if next != null: result.append_array(next.get_all_code(base_register, depth))
	return result

func delete() -> void:
	var graph: URCLGraph = get_parent()
	if graph != null: graph.delete_node(self)
