class_name Variable
extends Object

var owner: URCLGraph
var name: String: get = _get_name, set = _set_name
var title_get: String: get = _get_title_get
var title_set: String: get = _get_title_set
var _name: String = ""

signal renamed
signal deleted

func make_unique() -> void:
	var i: int = 0
	while owner.get_variable_by_name("variable_" + str(i)) != null: i += 1
	_name = "variable_" + str(i)

func add_get_node() -> void:
	var node: GetVariableNode = owner.add_node(GetVariableNode.new(), true)
	node.update_source(self)
	node.apply_style()
	connect("renamed", func():
		node.update_source(self)
	)
	connect("deleted", func():
		owner.delete_node(node)
	)

func add_set_node() -> void:
	var node: SetVariableNode = owner.add_node(SetVariableNode.new(), true)
	node.update_source(self)
	node.apply_style()
	connect("renamed", func():
		node.update_source(self)
	)
	connect("deleted", func():
		owner.delete_node(node)
	)

func get_index() -> int:
	return owner.get_variable_index(self)

func delete() -> void:
	emit_signal("deleted")

func _get_name() -> String: return _name
func _set_name(value: String) -> void:
	if owner.get_variable_by_name(value) == null:
		_name = value
		emit_signal("renamed")
func _get_title_get() -> String: return "Get " + _name.capitalize()
func _get_title_set() -> String: return "Set " + _name.capitalize()
