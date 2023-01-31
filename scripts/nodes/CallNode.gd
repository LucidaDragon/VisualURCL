class_name CallNode
extends URCLGraphNode

var source: FunctionNode

func _init() -> void:
	title = "Call"
	category = "Basic"
	pin_inputs.append_array(["exec_"])
	pin_outputs.append_array(["exec_"])

func set_source(source_node: FunctionNode) -> void:
	source = source_node
	source.connect("tree_exited", Callable(self, "delete"))
	source.connect("function_renamed", Callable(self, "update_labels"))
	update_labels()

func update_labels() -> void:
	title = source.get_caller_title()

func get_code(_base_register: int = 1, _depth: int = 0) -> Array[URCLInstruction]:
	if source.get_parent() != get_parent(): return []
	var cal = URCLCal.new()
	cal.operands.append(URCLLabel.create(source.get_function_name()))
	return [cal]

func get_next_node() -> URCLGraphNode:
	return get_output_nodes()[0]
