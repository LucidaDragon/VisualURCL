extends Window

var current_machine: URCLMachine

@onready var text_out = $TabContainer/Console/TextOut
@onready var text_in = $TabContainer/Console/TextIn
var text_buffer: Array[int] = []

@onready var screen = $TabContainer/Display/Aspect/Texture
@onready var width_box = $TabContainer/Display/HBox/WidthSpinBox
@onready var height_box = $TabContainer/Display/HBox/HeightSpinBox
@onready var autosize_check = $TabContainer/Display/HBox/AutoSizeButton
@onready var mode_box = $TabContainer/Display/HBox/ColorMenu
var screen_texture: ImageTexture = ImageTexture.new()
var screen_image: Image = Image.new()
var screen_buffer: Dictionary = {}
var screen_x: int = 0
var screen_y: int = 0

func _ready():
	connect("close_requested", func():
		if current_machine != null:
			current_machine.suspend()
			current_machine = null
		visible = false
		
		text_out.clear()
		text_in.clear()
		text_buffer.clear()
		
		width_box.value = 1
		height_box.value = 1
		autosize_check.button_pressed = true
		mode_box.selected = mode_box.item_count - 1
		screen_image.set_data(1, 1, false, Image.FORMAT_RGB8, PackedByteArray([0, 0, 0]))
	)
	
	text_in.connect("text_submitted", func(text: String):
		if current_machine == null: return
		text_in.text = ""
		for i in range(len(text)):
			text_buffer.append(text.unicode_at(i))
		text_buffer.append(10)
	)
	
	screen_image.set_data(1, 1, false, Image.FORMAT_RGB8, PackedByteArray([0, 0, 0]))
	screen_texture.set_image(screen_image)
	screen.texture = screen_texture

func bind_drivers(machine: URCLMachine, update_machine: bool = true) -> void:
	if update_machine:
		if current_machine == machine: return
		elif current_machine != null:
			current_machine.suspend()
			current_machine.free()
		
		current_machine = machine
	
	machine.in_ports["RAND"] = func():
		return randi() & machine.bitmask
	
	machine.in_ports["TEXT"] = func():
		if len(text_buffer) > 0:
			return text_buffer.pop_front()
		else:
			machine.suspend()
			machine.next_instruction -= 1
			return 0
	
	machine.out_ports["TEXT"] = func(value):
		text_out.insert_text_at_caret(String.chr(value))
	
	machine.out_ports["NUMB"] = func(value):
		text_out.insert_text_at_caret(str(value))
	
	machine.out_ports["X"] = func(value):
		screen_x = value
		if autosize_check.button_pressed and screen_x >= width_box.value:
			width_box.value = screen_x + 1
	
	machine.out_ports["Y"] = func(value):
		screen_y = value
		if autosize_check.button_pressed and screen_y >= height_box.value:
			height_box.value = screen_y + 1
	
	machine.out_ports["COLOR"] = func(value):
		if screen_x >= width_box.value or screen_y >= height_box.value: return
		if screen_image.get_width() != width_box.value or screen_image.get_height() != height_box.value:
			var new_image = Image.new()
			new_image.set_data(1, 1, false, Image.FORMAT_RGB8, PackedByteArray([0, 0, 0]))
			new_image.resize(width_box.value, height_box.value)
			new_image.blit_rect(screen_image, Rect2i(0, 0, width_box.value, height_box.value), Vector2i.ZERO)
			screen_image = new_image
		
		var color = get_color_from_value(value, mode_box.selected)
		screen_image.set_pixel(screen_x, screen_y, color)
		screen_texture.set_image(screen_image)
	
	machine.in_ports["COLORMODE"] = func():
		return mode_box.selected
	
	machine.out_ports["COLORMODE"] = func(value):
		if value > 16: value = 16
		mode_box.selected = value

func get_input_ports() -> Array[String]:
	var machine = URCLMachine.new()
	bind_drivers(machine, false)
	return machine.in_ports.keys()

func get_output_ports() -> Array[String]:
	var machine = URCLMachine.new()
	bind_drivers(machine, false)
	return machine.out_ports.keys()

func get_color_from_value(value: int, color_mode: int) -> Color:
	if color_mode >= 0 and color_mode <= 7:
		return get_grayscale_color(value, color_mode + 1)
	elif color_mode == 8:
		return get_rgb_color(value, 0x1, 0x2, 0x4)
	elif color_mode == 9:
		return get_rgbi_color(value)
	elif color_mode == 10:
		return get_rgb_color(value, 0x3, 0xC, 0x30)
	elif color_mode == 11:
		return get_rgb_color(value, 0x7, 0x38, 0xC0)
	elif color_mode == 12:
		return get_rgb_color(value, 0x7, 0x38, 0x1C0)
	elif color_mode == 13:
		return get_rgb_color(value, 0x1F, 0x3E0, 0x7C00)
	elif color_mode == 14:
		return get_rgb_color(value, 0x1F, 0x7E0, 0xF800)
	elif color_mode == 15:
		return get_rgb_color(value, 0x3F, 0xFC0, 0x3F000)
	elif color_mode == 16:
		return get_rgb_color(value, 0xFF, 0xFF00, 0xFF0000)
	return Color.BLACK

func get_grayscale_color(value: int, max_value: int) -> Color:
	if value > max_value: value = max_value
	var i: int = (value * 255) / max_value
	return Color(i, i, i)

func get_rgb_color(value: int, rbits: int, gbits: int, bbits: int) -> Color:
	var r: int = (get_masked_value(value, rbits) * 255) / get_masked_value(rbits, rbits)
	var g: int = (get_masked_value(value, gbits) * 255) / get_masked_value(gbits, gbits)
	var b: int = (get_masked_value(value, bbits) * 255) / get_masked_value(bbits, bbits)
	return Color(r / 255.0, g / 255.0, b / 255.0)

func get_masked_value(value: int, mask: int) -> int:
	while (mask & 1) == 0:
		value >>= 1
		mask >>= 1
	return value & mask

func get_rgbi_color(value: int) -> Color:
	return [
		Color(0, 0, 0),
		Color(0.50196081399918, 0, 0),
		Color(0, 0.50196081399918, 0),
		Color(0.50196081399918, 0.50196081399918, 0),
		Color(0, 0, 0.50196081399918),
		Color(0.50196081399918, 0, 0.50196081399918),
		Color(0, 0.50196081399918, 0.50196081399918),
		Color(0.50196081399918, 0.50196081399918, 0.50196081399918),
		Color(0.75294119119644, 0.75294119119644, 0.75294119119644),
		Color(1, 0, 0),
		Color(0, 1, 0),
		Color(1, 1, 0),
		Color(0, 0, 1),
		Color(1, 0, 1),
		Color(0, 1, 0),
		Color(1, 1, 1)
	][value & 0xF]

