class_name URCLOperand
extends Object

func can_read_direct(_machine: URCLMachine) -> bool:
	return false

func read_direct(_machine: URCLMachine) -> int:
	return 0

func can_write_direct(_machine: URCLMachine) -> bool:
	return false

func write_direct(_machine: URCLMachine, _value: int) -> void:
	pass

func can_read_indirect(_machine: URCLMachine) -> bool:
	return false

func read_indirect(_machine: URCLMachine) -> int:
	return 0

func can_write_indirect(_machine: URCLMachine) -> bool:
	return false

func write_indirect(_machine: URCLMachine, _value: int) -> void:
	pass

func can_read_io(_machine: URCLMachine) -> bool:
	return false

func read_io(_machine: URCLMachine) -> int:
	return 0

func can_write_io(_machine: URCLMachine) -> bool:
	return false

func write_io(_machine: URCLMachine, _value: int) -> void:
	pass

func get_string() -> String:
	return ""
