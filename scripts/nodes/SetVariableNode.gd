class_name SetVariableNode
extends URCLGraphNode

var source: Variable

func _init() -> void:
	title = "Set"
	category = "Variables"
	pin_inputs.append_array(["exec_", ""])
	pin_outputs.append_array(["exec_"])

func update_source(variable: Variable) -> void:
	source = variable
	title = variable.title_set

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
	
	var mov = URCLMov.new()
	mov.operands.append(URCLRegister.create(source.get_index() + 1))
	mov.operands.append(URCLRegister.create(base_register))
	result.append(mov)
	
	return result

func get_next_node() -> URCLGraphNode:
	return get_output_nodes()[0]
