class_name NodeMenu
extends PanelContainer

var variable_category: NodeCategory = preload("res://ui/NodeCategory.tscn").instantiate()
var function_category: NodeCategory = preload("res://ui/NodeCategory.tscn").instantiate()
@onready var search_box: LineEdit = $Split/SearchBox
@onready var arrangement: VBoxContainer = $Split/Scroll/Categories
var _current_focus: Control = null

func _init():
	hide()
	connect("visibility_changed", func():
		if search_box != null:
			if visible: search_box.grab_focus()
			else:
				search_box.text = ""
				clear_filter()
	)

func _ready():
	search_box.connect("gui_input", func(event):
		if event is InputEventKey and event.pressed and event.keycode == KEY_DOWN:
			var simulated_tab = InputEventKey.new()
			simulated_tab.keycode = KEY_TAB
			simulated_tab.pressed = true
			Input.parse_input_event(simulated_tab)
	)
	search_box.connect("text_changed", Callable(self, "apply_filter"))
	monitor_focus(search_box)
	
	arrangement.connect("sort_children", func():
		var children = arrangement.get_children()
		children.sort_custom(func(a, b):
			return a.text < b.text
		)
		for i in range(len(children)):
			arrangement.move_child(children[i], i)
	)
	
	variable_category.text = "Variables"
	variable_category.connect("ready", func(): monitor_focus(variable_category.button))
	arrangement.add_child(variable_category)
	
	function_category.text = "Functions"
	function_category.connect("ready", func(): monitor_focus(function_category.button))
	arrangement.add_child(function_category)

func _process(_delta):
	var viewport_size = get_viewport().size
	size = Vector2(viewport_size.x / 6.0, viewport_size.y / 4.0)
	if visible and _current_focus == null: hide()

func monitor_focus(control: Control) -> void:
	control.connect("focus_entered", func():
		_current_focus = control
	)
	control.connect("focus_exited", func():
		if _current_focus == control: _current_focus = null
	)

func show_menu() -> void:
	show_menu_at(get_viewport().get_mouse_position())

func show_menu_at(pos: Vector2) -> void:
	position = pos
	show()

func add_node(template: URCLGraphNode) -> Button:
	var category: NodeCategory = arrangement.get_node_or_null(template.category)
	if category == null:
		category = preload("res://ui/NodeCategory.tscn").instantiate()
		category.text = template.category
		category.connect("ready", func(): monitor_focus(category.button))
		arrangement.add_child(category)
	var button = category.add_node(template)
	button.connect("pressed", Callable(self, "hide"))
	monitor_focus(button)
	return button

func add_function(func_node: FunctionNode) -> void:
	monitor_focus(function_category.add_function(func_node))

func add_variable(variable: Variable) -> void:
	for button in variable_category.add_variable(variable): monitor_focus(button)

func clear_filter() -> void:
	for category in arrangement.get_children():
		if category is NodeCategory: category.clear_filter()

func apply_filter(contains: String) -> void:
	if contains == "":
		clear_filter()
	else:
		for category in arrangement.get_children():
			if category is NodeCategory: category.apply_filter(contains)
