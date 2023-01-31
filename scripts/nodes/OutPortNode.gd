class_name OutPortNode
extends URCLGraphNode

func _init() -> void:
	title = "Write Port (Unknown)"
	category = "Ports"
	pin_inputs.append_array(["exec_", ""])
	pin_outputs.append_array(["exec_"])
	editor_description = "unknown"

func set_target_port(port_name: String) -> void:
	editor_description = port_name
	title = "Write Port (" + port_name.capitalize() + ")"

func get_code(base_register: int = 1, depth: int = 0) -> Array[URCLInstruction]:
	var inputs = get_input_nodes()
	var result: Array[URCLInstruction] = []
	
	if inputs[1] == null:
		var zero = URCLMov.new()
		zero.operands.append(URCLRegister.create(base_register))
		zero.operands.append(URCLRegister.create(0))
		result.append(zero)
	else:
		result += inputs[1].get_code(base_register, depth + 1)
	
	var output = URCLOut.new()
	output.operands.append(URCLPort.create(editor_description))
	output.operands.append(URCLRegister.create(base_register))
	result.append(output)
	
	return result

func get_next_node() -> URCLGraphNode:
	return get_output_nodes()[0]
