class_name URCLIn
extends URCLInstruction

func validate(machine: URCLMachine) -> bool:
	if len(operands) != 2:
		machine.report_error(self, "Expected 2 operands.")
		return false
	
	if not operands[0].can_write_direct(machine):
		machine.report_error(self, "Operand 1 does not allow direct write access.")
		return false
	
	if not operands[1].can_read_io(machine):
		machine.report_error(self, "Operand 2 does not allow I/O read access.")
		return false
	
	return true

func execute(machine: URCLMachine) -> void:
	operands[0].write_direct(machine, operands[1].read_io(machine))
