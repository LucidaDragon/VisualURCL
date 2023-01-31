class_name TrueNode
extends URCLGraphNode

func _init() -> void:
	title = "True"
	category = "Boolean"
	pin_inputs.append_array([])
	pin_outputs.append_array(["bool_"])

func get_code(base_register: int = 1, _depth: int = 0) -> Array[URCLInstruction]:
	var imm = URCLImm.new()
	imm.operands.append(URCLRegister.create(base_register))
	imm.operands.append(URCLImmediate.create(1))
	return [imm]
