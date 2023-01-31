class_name BranchNode
extends URCLGraphNode

func _init() -> void:
	title = "Branch"
	category = "Basic"
	pin_inputs.append_array(["exec_", "bool_"])
	pin_outputs.append_array(["exec_True", "exec_False"])

func get_code(base_register: int = 1, depth: int = 0) -> Array[URCLInstruction]:
	var inputs = get_input_nodes()
	var outputs = get_output_nodes()
	
	var result: Array[URCLInstruction] = []
	
	if outputs[0] == outputs[1]: return result
	
	if inputs[1] == null:
		var zero = URCLMov.new()
		zero.operands.append(URCLRegister.create(base_register))
		zero.operands.append(URCLRegister.create(0))
		result.append(zero)
	else:
		result += inputs[1].get_code(base_register, depth + 1)
	
	var label = create_new_label()
	
	if outputs[0] == null or outputs[1] == null:
		var skip_branch: URCLInstruction = URCLBnz.new() if outputs[0] == null else URCLBrz.new()
		skip_branch.operands.append(label)
		skip_branch.operands.append(URCLRegister.create(base_register))
		
		var end = URCLMarkLabel.new()
		end.operands.append(label)
		
		result.append(skip_branch)
		for node in get_branch_until(outputs[0] != null, get_next_node()):
			result.append_array(node.get_code(base_register, depth))
		result.append(end)
	else:
		var end_label = create_new_label()
		
		var branch = URCLBrz.new()
		branch.operands.append(label)
		branch.operands.append(URCLRegister.create(base_register))
		
		var false_path = URCLMarkLabel.new()
		false_path.operands.append(label)
		
		var end_jump = URCLJmp.new()
		end_jump.operands.append(end_label)
		
		var end = URCLMarkLabel.new()
		end.operands.append(end_label)
		
		var next_node = get_next_node()
		result.append(branch)
		for node in get_branch_until(true, next_node):
			result.append_array(node.get_code(base_register, depth))
		result.append(end_jump)
		result.append(false_path)
		for node in get_branch_until(false, next_node):
			result.append_array(node.get_code(base_register, depth))
		result.append(end)
	
	return result

func get_branch_until(branch: bool, end: URCLGraphNode) -> Array[URCLGraphNode]:
	var current: URCLGraphNode = get_output_nodes()[0] if branch else get_output_nodes()[1]
	var result: Array[URCLGraphNode] = []
	while current != end:
		result.append(current)
		current = current.get_next_node()
	return result

func get_next_node() -> URCLGraphNode:
	var outputs = get_output_nodes()
	if outputs[0] == null or outputs[1] == null:
		#There is either one branch or no next node.
		return null
	elif outputs[0] == outputs[1]:
		#Both branches connect to the same next node.
		return outputs[0]
	else:
		#Find the next node that both branches have in common.
		var true_branch: Array[URCLGraphNode] = [outputs[0]]
		var false_branch: Array[URCLGraphNode] = [outputs[1]]
		var next_true = outputs[0].get_next_node()
		var next_false = outputs[1].get_next_node()
		
		while next_true != null or next_false != null:
			if next_true != null:
				if next_true in false_branch: return next_true
				true_branch.append(next_true)
				next_true = next_true.get_next_node()
			if next_false != null:
				if next_false in true_branch: return next_false
				false_branch.append(next_false)
				next_false = next_false.get_next_node()
		
		return null

func get_branches() -> Array[URCLGraphNode]:
	var outputs = get_output_nodes()
	var result: Array[URCLGraphNode] = []
	result.append_array([outputs[0], outputs[1]])
	return result
