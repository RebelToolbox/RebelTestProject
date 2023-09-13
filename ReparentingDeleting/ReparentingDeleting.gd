# This test adds nodes to scene, then chooses some random nodes and:
# - reparents them
# - deletes them and replaces them with new ones
extends Node

var number_of_nodes: int = 0
# Collected nodes
var collected_nodes: Array = []
# Disabled nodes which won't be used
var disabled_classes: Array = [
	"ReflectionProbe", # GH 45460
]
var debug_enabled: bool = false

func collect() -> void:
	var classes: Array = ClassDB.get_class_list()
	classes.sort()
	for name_of_class in classes:
		if ClassDB.is_parent_class(name_of_class, "Node"):
			# We don't want to test editor nodes
			if name_of_class.find("Editor") != -1:
				continue
			if disabled_classes.has(name_of_class):
				continue
			# Only instantable nodes can be used
			if ClassDB.can_instance(name_of_class):
				collected_nodes.append(name_of_class)
	if debug_enabled:
		var to_print: String = "DEBUG: List of classes used in ReparentingDeleting scene:\n"
		to_print += "DEBUG: ["
		for index in range(classes.size()):
			to_print += "\"" + classes[index] + "\""
			if index != classes.size() - 1:
				to_print += ", "
		print(to_print)

func _ready() -> void:
	seed(405)
	collect()
	# Use at least all the nodes (There are currently around 168 nodes).
	number_of_nodes = max(collected_nodes.size(), 200)
	for i in range(number_of_nodes):
		var index = i
		# Wrap values
		if i >= collected_nodes.size():
			index = i % collected_nodes.size()
		var child: Node = ClassDB.instance(collected_nodes[index])
		child.set_name("Special Node " + str(i))
		add_child(child)

func _process(delta: float) -> void:
	var choosen_node: Node
	var parent_of_node: Node
	for i in range(5):
		var number: String = "Special Node " + str(randi() % number_of_nodes)
		choosen_node = find_node(number, true, false)
		parent_of_node = choosen_node.get_parent()
		var random_node = find_node("Special Node " + str(randi() % number_of_nodes), true, false)
		parent_of_node.remove_child(choosen_node)
		# Around 16% chance that we remove the node and its children
		if randi() % 6 == 0:
			var names_to_remove: Array = find_all_special_children_names(choosen_node)
			for name_to_remove in names_to_remove:
				var node: Node = ClassDB.instance(collected_nodes[randi() % collected_nodes.size()])
				node.set_name(name_to_remove)
				add_child(node)
			choosen_node.queue_free()
			continue
		# Cannot set a node's child as the node's parent.
		if choosen_node.find_node(random_node.get_name(), true, false) != null:
			add_child(choosen_node)
			continue
		# Do not reparent the node to itself.
		if choosen_node == random_node:
			add_child(choosen_node)
			continue
		random_node.add_child(choosen_node)

# Recusivelly find all Special child nodes
func find_all_special_children_names(node: Node) -> Array:
	var array: Array = []
	array.append(node.get_name())
	for child in node.get_children():
		if child.get_name().begins_with("Special Node"):
			array.append_array(find_all_special_children_names(child))
	return array
