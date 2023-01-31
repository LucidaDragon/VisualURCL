class_name PropertyPanel
extends PanelContainer

@onready var arrangement = $Scroll/Arrangement
@onready var add_button = $Scroll/Arrangement/AddButton
@onready var graph: URCLGraph = $"../GraphEdit"

func _ready():
	add_button.connect("pressed", func():
		var property = HBoxContainer.new()
		var name_box = LineEdit.new()
		var delete_button = Button.new()
		var variable = graph.create_variable()
		var submit_text = func():
			variable.name = name_box.text
			name_box.text = variable.name
		
		property.connect("tree_exited", func():
			variable.delete()
		)
		
		name_box.text = variable.name
		name_box.size_flags_horizontal = SIZE_EXPAND_FILL
		name_box.connect("focus_exited", submit_text)
		name_box.connect("text_submitted", func(_new_text):
			submit_text.call()
		)
		
		delete_button.icon = preload("res://icons/remove.svg")
		delete_button.flat = true
		delete_button.focus_mode = Control.FOCUS_NONE
		delete_button.connect("pressed", Callable(property, "queue_free"))
		
		property.add_child(name_box)
		property.add_child(delete_button)
		
		arrangement.add_child(property)
		arrangement.remove_child(add_button)
		arrangement.add_child(add_button)
	)
