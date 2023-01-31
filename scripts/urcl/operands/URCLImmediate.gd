class_name URCLImmediate
extends URCLOperand

static func create(immediate_value: int) -> URCLImmediate:
	var result = URCLImmediate.new()
	result.value = immediate_value
	return result

@export var value: int = 0

func can_read_direct(_machine: URCLMachine) -> bool:
	return true

func read_direct(_machine: URCLMachine) -> int:
	return value

func get_string() -> String:
	return str(value)
