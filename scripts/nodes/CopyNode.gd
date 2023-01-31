class_name CopyNode
extends URCLGraphNode

func _init() -> void:
	title = "Copy"
	category = "Memory"
	pin_inputs.append_array(["exec_", "Source", "Destination"])
	pin_outputs.append_array(["exec_"])

func get_code(base_register: int = 1, depth: int = 0) -> Array[URCLInstruction]:
	var inputs = get_input_nodes()
	var result: Array[URCLInstruction] = []
	
	for input in range(2):
		if inputs[input + 1] == null:
			var zero = URCLMov.new()
			zero.operands.append(URCLRegister.create(base_register + input))
			zero.operands.append(URCLRegister.create(0))
			result.append(zero)
		else:
			result += inputs[input + 1].get_code(base_register + input, depth + 1)
	
	var cpy = URCLCpy.new()
	cpy.operands.append(URCLRegister.create(base_register))
	cpy.operands.append(URCLRegister.create(base_register + 1))
	result.append(cpy)
	
	return result

func get_next_node() -> URCLGraphNode:
	return get_output_nodes()[0]
