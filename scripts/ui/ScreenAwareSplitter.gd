extends SplitContainer

@export var initial_split: float = 0.80
@onready var is_vertical: bool = get_node(".") is VSplitContainer
@onready var is_horizontal: bool = get_node(".") is HSplitContainer
var _last_viewport_size: Vector2i = Vector2i.ONE

func _ready():
	var node: Node = self
	while node != null:
		if node is Control or node is Viewport:
			node.connect("resized" if node is Control else "size_changed", Callable(self, "update_split_offset"))
		node = node.get_parent()
	var viewport = get_viewport()
	split_offset = initial_split * (viewport.size.x if is_horizontal else viewport.size.y)
	_last_viewport_size = viewport.size

func update_split_offset():
	if is_vertical or is_horizontal:
		var viewport = get_viewport()
		if viewport.size != _last_viewport_size:
			var old_relative_offset = split_offset / float(_last_viewport_size.x if is_horizontal else _last_viewport_size.y)
			split_offset = int(old_relative_offset * (viewport.size.x if is_horizontal else viewport.size.y))
			_last_viewport_size = viewport.size
