class_name InPortNode
extends URCLGraphNode

func _init() -> void:
	title = "Read Port (Unknown)"
	category = "Ports"
	pin_outputs.append_array([""])
	editor_description = "unknown"

func set_target_port(port_name: String) -> void:
	editor_description = port_name
	title = "Read Port (" + port_name.capitalize() + ")"

func get_code(base_register: int = 1, _depth: int = 0) -> Array[URCLInstruction]:
	var result: Array[URCLInstruction] = []
	
	var input = URCLIn.new()
	input.operands.append(URCLRegister.create(base_register))
	input.operands.append(URCLPort.create(editor_description))
	result.append(input)
	
	return result
