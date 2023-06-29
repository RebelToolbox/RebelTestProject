# This test adds and removes nodes to and from the scene tree
extends Node

const TIME_TO_DELETE: float = 3.0

var time_to_delete: float = TIME_TO_DELETE
var disabled_classes: Array = []
var classes: Array = []
var debug_enabled: bool = false

# Collects all classes which will be used
func collect() -> void:
	for name_of_class in ClassDB.get_class_list():
		if name_of_class in disabled_classes:
			continue
		if !ClassDB.can_instance(name_of_class):
			continue
		if ClassDB.is_parent_class(name_of_class, "Control"):
			classes.append(name_of_class)
			continue
		if ClassDB.is_parent_class(name_of_class, "Spatial"):
			classes.append(name_of_class)
			continue
		if ClassDB.is_parent_class(name_of_class, "Node2D"):
			classes.append(name_of_class)
			continue
		if ClassDB.get_parent_class(name_of_class) == "Node":
			classes.append(name_of_class)
			continue
	classes.sort()
	if debug_enabled:
		var to_print: String = "DEBUG: List of classes used in Nodes scene:\n"
		to_print += "DEBUG: ["
		for index in range(classes.size()):
			to_print += "\"" + classes[index] + "\""
			if index != classes.size() - 1:
				to_print += ", "
		print(to_print)

# Adds nodes to the scene
func populate() -> void:
	for _i in range(2):
		for name_of_class in classes:
			add_child(ClassDB.instance(name_of_class))

func _ready() -> void:
	collect()
	populate()

func _process(delta: float) -> void:
	# Moves nodes a little
	for i in get_children():
		if i is Control:
			i._set_size(Vector2(200 * randf() - 100, 200 * randf() - 100))
		if i is Node2D:
			i.set_position(Vector2(1000 * randf() - 500, 1000 * randf() - 500))
		if i is Spatial:
			if i.get_name() != "Camera":
				i.set_scale(Vector3(delta + 1, delta + 1, delta + 1))
				i.set_translation(Vector3(10 * randf(), 10 * randf(), 10 * randf()))
	time_to_delete -= delta
	# Delete and readd nodes
	if time_to_delete < 0:
		if debug_enabled:
			print("DEBUG: Deleting nodes")
		time_to_delete += TIME_TO_DELETE
		for i in get_children():
			i.queue_free()
		if debug_enabled:
			print("DEBUG: Adding nodes")
		populate()
