class_name IntegerNode
extends URCLGraphNode

func _init() -> void:
	title = "Integer"
	category = "Integer"
	pin_inputs.append_array(["const_"])
	pin_outputs.append_array([""])

func get_code(base_register: int = 1, _depth: int = 0) -> Array[URCLInstruction]:
	var imm = URCLImm.new()
	imm.operands.append(URCLRegister.create(base_register))
	imm.operands.append(URCLImmediate.create(get_constant_inputs()[0].value))
	return [imm]
