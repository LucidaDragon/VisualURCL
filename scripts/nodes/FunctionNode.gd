class_name FunctionNode
extends URCLGraphNode

var _last_name: String = ""

signal function_renamed

func _init() -> void:
	title = "Function"
	category = "Basic"
	pin_inputs.append("label_")
	pin_outputs.append("exec_")

func get_caller_title() -> String:
	return "Call " + get_function_name().capitalize()

func get_function_name() -> String:
	return get_constant_inputs()[0].text

func set_function_name(func_name: String) -> void:
	get_constant_inputs()[0].text = func_name

func get_code(base_register: int = 1, _depth: int = 0) -> Array[URCLInstruction]:
	var label = URCLMarkLabel.new()
	label.operands.append(URCLLabel.create(get_function_name()))
	var outputs = get_output_nodes()
	return [label, URCLRet.new()] if outputs[0] == null else [label] + outputs[0].get_all_code(base_register) + [URCLRet.new()]

func update_labels() -> void:
	var new_name = get_function_name()
	if new_name != _last_name:
		_last_name = new_name
		emit_signal("function_renamed")
