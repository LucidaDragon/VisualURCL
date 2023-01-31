class_name URCLMachine
extends Object

class Error:
	var offset: int = 0
	var message: String = ""

var bitmask: int = 0xFFFFFFFF
var errors: Array[Error] = []
var stack_pointer: int = 0
var registers: Array[int] = []
var memory: Dictionary = {}
var in_ports: Dictionary = {}
var out_ports: Dictionary = {}
var instructions: Array[URCLInstruction] = []
var next_instruction: int = -1
var suspended: bool = false

func get_bits() -> int:
	var result: int = 0
	var bits: int = bitmask
	while (bits & 1) != 0:
		result += 1
		bits >>= 1
	return result

func validate() -> bool:
	memory.clear()
	stack_pointer = 0
	push(bitmask)
	errors.clear()
	var result: bool = true
	for instruction in instructions:
		result = instruction.validate(self) and result
	return result

func execute(entry_point: int = 0) -> void:
	next_instruction = entry_point if validate() else -1
	resume()

func step() -> void:
	if next_instruction >= 0 and next_instruction < len(instructions) and not suspended:
		var current_instruction = next_instruction
		next_instruction += 1
		instructions[current_instruction].execute(self)

func suspend() -> void:
	suspended = true

func resume() -> void:
	suspended = false

func report_error(instruction: URCLInstruction, message: String) -> void:
	var error = Error.new()
	error.offset = instructions.find(instruction)
	error.message = message
	errors.append(error)

func get_label(name: String) -> int:
	for i in range(len(instructions)):
		var instruction = instructions[i]
		if instruction is URCLMarkLabel:
			var label: URCLLabel = instruction.operands[0]
			if label.name == name: return i
	return -1

func get_sign_bit() -> int:
	return 1 << (get_bits() - 1)

func get_signed(unsigned: int) -> int:
	return (unsigned & (bitmask >> 1)) | ((-1 << (get_bits() - 1)) if (unsigned & get_sign_bit()) != 0 else 0)

func get_unsigned(signed: int) -> int:
	return (signed & bitmask) | (get_sign_bit() if signed < 0 else 0)

func get_memory_word(address: int) -> int:
	return (memory[address & bitmask] & bitmask) if (address & bitmask) in memory else 0

func set_memory_word(address: int, value: int) -> void:
	memory[address & bitmask] = value & bitmask

func get_register(index: int) -> int:
	return (registers[index] & bitmask) if len(registers) > index and index > 0 else 0

func set_register(index: int, value: int) -> void:
	if index > 0:
		if index >= len(registers):
			var start = len(registers)
			registers.resize(index + 1)
			for i in range(start, index + 1): registers[i] = 0
		registers[index] = value & bitmask

func has_label(name: String) -> bool:
	return get_label(name) != -1

func jump_to_label(name: String) -> void:
	jump_to_address(get_label(name))

func jump_to_address(address: int) -> void:
	next_instruction = address

func can_read_io(port: String) -> bool:
	return port.to_upper() in in_ports

func can_write_io(port: String) -> bool:
	return port.to_upper() in out_ports

func read_io(port: String) -> int:
	return in_ports[port.to_upper()].call() & bitmask

func write_io(port: String, value: int) -> void:
	out_ports[port.to_upper()].call(value & bitmask)

func push(value: int) -> void:
	stack_pointer = (stack_pointer - 1) & bitmask
	set_memory_word(stack_pointer, value)

func pop() -> int:
	var result = get_memory_word(stack_pointer)
	stack_pointer = (stack_pointer + 1) & bitmask
	return result

func get_string() -> String:
	var result: String = ""
	for instruction in instructions:
		result += instruction.get_string() + "\n"
	return result
