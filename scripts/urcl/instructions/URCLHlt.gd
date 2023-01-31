class_name URCLHlt
extends URCLInstruction

func validate(machine: URCLMachine) -> bool:
	if len(operands) != 0:
		machine.report_error(self, "Expected 0 operands.")
		return false
	
	return true

func execute(machine: URCLMachine) -> void:
	machine.next_instruction -= 1
	machine.suspend()
