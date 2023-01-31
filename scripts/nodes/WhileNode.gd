class_name WhileNode
extends URCLGraphNode

func _init() -> void:
	title = "While"
	category = "Basic"
	pin_inputs.append_array(["exec_", "bool_"])
	pin_outputs.append_array(["exec_Loop Body", "exec_Completed"])

func get_code(base_register: int = 1, depth: int = 0) -> Array[URCLInstruction]:
	var inputs = get_input_nodes()
	var outputs = get_output_nodes()
	
	var result: Array[URCLInstruction] = []
	
	var label = create_new_label()
	var top = URCLMarkLabel.new()
	top.operands.append(label)
	
	result.append(top)
	
	if inputs[1] == null:
		var zero = URCLMov.new()
		zero.operands.append(URCLRegister.create(base_register))
		zero.operands.append(URCLRegister.create(0))
		result.append(zero)
	else:
		result += inputs[1].get_code(base_register, depth + 1)
	
	if outputs[0] == null:
		var branch = URCLBnz.new()
		branch.operands.append(label)
		branch.operands.append(URCLRegister.create(base_register))
		result.append(branch)
	else:
		var end_label = create_new_label()
		
		var branch = URCLBrz.new()
		branch.operands.append(end_label)
		branch.operands.append(URCLRegister.create(base_register))
		
		var top_jump = URCLJmp.new()
		top_jump.operands.append(label)
		
		var end = URCLMarkLabel.new()
		end.operands.append(end_label)
		
		result.append(branch)
		result.append_array(outputs[0].get_all_code(base_register, depth))
		result.append(top_jump)
		result.append(end)
	
	return result

func get_next_node() -> URCLGraphNode:
	return get_output_nodes()[1]

func get_branches() -> Array[URCLGraphNode]:
	var outputs = get_output_nodes()
	var result: Array[URCLGraphNode] = []
	result.append_array([outputs[0], outputs[1]])
	return result
