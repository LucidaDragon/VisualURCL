class_name AddNode
extends URCLGraphNode

func _init() -> void:
	title = "Add"
	category = "Integer"
	pin_inputs.append_array(["", ""])
	pin_outputs.append_array([""])

func get_code(base_register: int = 1, depth: int = 0) -> Array[URCLInstruction]:
	var inputs = get_input_nodes()
	var result: Array[URCLInstruction] = []
	
	for input in range(2):
		if inputs[input] == null:
			var zero = URCLMov.new()
			zero.operands.append(URCLRegister.create(base_register + input))
			zero.operands.append(URCLRegister.create(0))
			result.append(zero)
		else:
			result += inputs[input].get_code(base_register + input, depth + 1)
	
	var add = URCLAdd.new()
	add.operands.append(URCLRegister.create(base_register))
	add.operands.append(URCLRegister.create(base_register))
	add.operands.append(URCLRegister.create(base_register + 1))
	result.append(add)
	
	return result
