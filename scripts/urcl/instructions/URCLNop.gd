class_name URCLNop
extends URCLInstruction

func validate(machine: URCLMachine) -> bool:
	if len(operands) != 0:
		machine.report_error(self, "Expected 0 operands.")
		return false
	
	return true

func execute(machine: URCLMachine) -> void:
	pass
