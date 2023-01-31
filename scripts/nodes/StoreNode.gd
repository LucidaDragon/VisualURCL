class_name StoreNode
extends URCLGraphNode

func _init() -> void:
	title = "Store"
	category = "Memory"
	pin_inputs.append_array(["exec_", "Address", "Value"])
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
	
	var store = URCLStr.new()
	store.operands.append(URCLRegister.create(base_register))
	store.operands.append(URCLRegister.create(base_register + 1))
	result.append(store)
	
	return result

func get_next_node() -> URCLGraphNode:
	return get_output_nodes()[0]
