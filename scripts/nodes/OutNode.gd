class_name OutNode
extends URCLGraphNode

func _init() -> void:
	title = "Write Port"
	category = "Ports"
	pin_inputs.append_array(["exec_", "", "port_"])
	pin_outputs.append_array(["exec_"])

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
	output.operands.append(URCLPort.create(get_constant_inputs()[0].text))
	output.operands.append(URCLRegister.create(base_register))
	result.append(output)
	
	return result

func get_next_node() -> URCLGraphNode:
	return get_output_nodes()[0]
