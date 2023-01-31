class_name IsZeroNode
extends URCLGraphNode

func _init() -> void:
	title = "Is Zero"
	category = "Integer"
	pin_inputs.append_array([""])
	pin_outputs.append_array(["bool_"])

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
	
	var setif = URCLSete.new()
	setif.operands.append(URCLRegister.create(base_register))
	setif.operands.append(URCLRegister.create(base_register))
	setif.operands.append(URCLRegister.create(0))
	result.append(setif)
	
	return result
