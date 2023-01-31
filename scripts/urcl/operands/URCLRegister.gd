class_name URCLRegister
extends URCLOperand

static func create(register_index: int) -> URCLRegister:
	var result = URCLRegister.new()
	result.index = register_index
	return result

@export var index: int = 0

func can_read_direct(_machine: URCLMachine) -> bool:
	return true

func read_direct(machine: URCLMachine) -> int:
	return machine.get_register(index)

func can_write_direct(_machine: URCLMachine) -> bool:
	return true

func write_direct(machine: URCLMachine, value: int) -> void:
	machine.set_register(index, value)

func can_read_indirect(_machine: URCLMachine) -> bool:
	return true

func read_indirect(machine: URCLMachine) -> int:
	return machine.get_memory_word(machine.get_register(index))

func can_write_indirect(_machine: URCLMachine) -> bool:
	return true

func write_indirect(machine: URCLMachine, value: int) -> void:
	machine.set_memory_word(machine.get_register(index), value)

func get_string() -> String:
	return "R" + str(index) if index > 0 else "R0"
