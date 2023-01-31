class_name FalseNode
extends URCLGraphNode

func _init() -> void:
	title = "False"
	category = "Boolean"
	pin_inputs.append_array([])
	pin_outputs.append_array(["bool_"])

func get_code(base_register: int = 1, _depth: int = 0) -> Array[URCLInstruction]:
	var imm = URCLImm.new()
	imm.operands.append(URCLRegister.create(base_register))
	imm.operands.append(URCLImmediate.create(0))
	return [imm]
