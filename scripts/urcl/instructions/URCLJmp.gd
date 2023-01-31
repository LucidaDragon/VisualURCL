class_name URCLJmp
extends URCLInstruction

func validate(machine: URCLMachine) -> bool:
	if len(operands) != 1:
		machine.report_error(self, "Expected 1 operands.")
		return false
	
	if not operands[0].can_read_direct(machine):
		machine.report_error(self, "Operand 1 does not allow direct read access.")
		return false
	
	return true

func execute(machine: URCLMachine) -> void:
	machine.jump_to_address(operands[0].read_direct(machine))
