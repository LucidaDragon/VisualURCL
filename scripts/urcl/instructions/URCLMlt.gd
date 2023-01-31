class_name URCLMlt
extends URCLInstruction

func validate(machine: URCLMachine) -> bool:
	if len(operands) != 3:
		machine.report_error(self, "Expected 3 operands.")
		return false
	
	if not operands[0].can_write_direct(machine):
		machine.report_error(self, "Operand 1 does not allow direct write access.")
		return false
	
	if not operands[1].can_read_direct(machine):
		machine.report_error(self, "Operand 2 does not allow direct read access.")
		return false
	
	if not operands[2].can_read_direct(machine):
		machine.report_error(self, "Operand 3 does not allow direct read access.")
		return false
	
	return true

func execute(machine: URCLMachine) -> void:
	operands[0].write_direct(machine, operands[1].read_direct(machine) * operands[2].read_direct(machine))
