class_name URCLInstruction
extends Object

var operands: Array[URCLOperand] = []

func validate(_machine: URCLMachine) -> bool:
	return false

func execute(_machine: URCLMachine) -> void:
	pass

func get_string() -> String:
	var result: String = str(get_script().get_path()).get_file().substr(4).to_lower()
	result = result.substr(0, result.find(".")) + " "
	for operand in operands: result += operand.get_string() + " "
	return result
