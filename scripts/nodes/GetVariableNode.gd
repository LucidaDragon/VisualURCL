class_name GetVariableNode
extends URCLGraphNode

var source: Variable

func _init() -> void:
	title = "Get"
	category = "Variables"
	pin_inputs.append_array([])
	pin_outputs.append_array([""])

func update_source(variable: Variable) -> void:
	source = variable
	title = variable.title_get

func get_code(base_register: int = 1, _depth: int = 0) -> Array[URCLInstruction]:
	var result: Array[URCLInstruction] = []
	
	var mov = URCLMov.new()
	mov.operands.append(URCLRegister.create(base_register))
	mov.operands.append(URCLRegister.create(source.get_index() + 1))
	result.append(mov)
	
	return result
