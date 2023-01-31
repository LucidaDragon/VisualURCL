class_name URCLPort
extends URCLOperand

static func create(port_name: String) -> URCLPort:
	var result = URCLPort.new()
	result.port = port_name
	return result

@export var port: String = ""

func can_read_io(machine: URCLMachine) -> bool:
	return machine.can_read_io(port)

func read_io(machine: URCLMachine) -> int:
	return machine.read_io(port)

func can_write_io(machine: URCLMachine) -> bool:
	return machine.can_write_io(port)

func write_io(machine: URCLMachine, value: int) -> void:
	machine.write_io(port, value)

func get_string() -> String:
	return "%" + port
