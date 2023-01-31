class_name URCLLabel
extends URCLOperand

static func create(label_name: String) -> URCLLabel:
	var result = URCLLabel.new()
	result.name = label_name
	return result

@export var name: String = ""

func can_read_direct(machine: URCLMachine) -> bool:
	return machine.has_label(name)

func read_direct(machine: URCLMachine) -> int:
	return machine.get_label(name)

func get_string() -> String:
	return "." + str(name)
