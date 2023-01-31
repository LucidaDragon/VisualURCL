class_name InNode
extends URCLGraphNode

func _init() -> void:
	title = "Read Port"
	category = "Ports"
	pin_inputs.append_array(["port_"])
	pin_outputs.append_array([""])

func get_code(base_register: int = 1, _depth: int = 0) -> Array[URCLInstruction]:
	var result: Array[URCLInstruction] = []
	
	var input = URCLIn.new()
	input.operands.append(URCLRegister.create(base_register))
	input.operands.append(URCLPort.create(get_constant_inputs()[0].text))
	result.append(input)
	
	return result
