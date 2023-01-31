class_name LoadNode
extends URCLGraphNode

func _init() -> void:
	title = "Load"
	category = "Memory"
	pin_inputs.append_array(["Address"])
	pin_outputs.append_array(["Value"])

func get_code(base_register: int = 1, depth: int = 0) -> Array[URCLInstruction]:
	var inputs = get_input_nodes()
	var result: Array[URCLInstruction] = []
	
	if inputs[0] == null:
		var zero = URCLMov.new()
		zero.operands.append(URCLRegister.create(base_register))
		zero.operands.append(URCLRegister.create(0))
		result.append(zero)
	else:
		result += inputs[0].get_code(base_register, depth + 1)
	
	var lod = URCLLod.new()
	lod.operands.append(URCLRegister.create(base_register))
	lod.operands.append(URCLRegister.create(base_register))
	result.append(lod)
	
	return result
