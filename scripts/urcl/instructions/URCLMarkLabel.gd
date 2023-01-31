class_name URCLMarkLabel
extends URCLInstruction

func validate(machine: URCLMachine) -> bool:
	if len(operands) != 1:
		machine.report_error(self, "Expected 1 operands.")
		return false
	
	return true

func execute(_machine: URCLMachine) -> void: return

func get_string() -> String:
	return operands[0].get_string()
