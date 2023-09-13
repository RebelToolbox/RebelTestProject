# This test instantiates all classes
extends Node2D

var available_classes : Array = []
var disabled_classes : Array = ["SceneTree", "EditorSettings", "ProjectSettings"]

func _ready():
	var classes : Array = Array(ClassDB.get_class_list())
	classes.sort()
	for name_of_class in classes:
		if !ClassDB.can_instance(name_of_class):
			continue
		if name_of_class in disabled_classes:
			continue
		if name_of_class.to_lower().find("server") != -1:
			continue
		print("Creating: " + name_of_class)
		print("GDSCRIPT CODE: var thing = ClassDB.instance(\"" + name_of_class + "\")")
		var thing = ClassDB.instance(name_of_class)
		print("GDSCRIPT CODE: str(" + name_of_class + ")")
		str(thing)
		if thing is Node:
			print("GDSCRIPT CODE: thing.queue_free()")
			thing.queue_free()
		elif thing is Object && !(thing is Reference):
			print("GDSCRIPT CODE: thing.free()")
			thing.free()
