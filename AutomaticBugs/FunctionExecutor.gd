# This test obtains all the methods in all the classes and calls them
extends Node

var debug_enabled: bool = true
# Adds nodes to tree
# TODO: Project freezes when removing a lot of nodes
var add_to_tree: bool = false
# For example, allows Node2D to use Node's methods
var use_parent_methods: bool = false
# Don't remember other methods' effects
var always_create_new_object: bool = true
var exiting: bool = false

func _ready() -> void:
	if BasicData.regression_testing:
		# Make results reproducible
		ValueCreator.random = false
	else:
		ValueCreator.random = true
	ValueCreator.number = 100
	ValueCreator.should_be_always_valid = false
	if BasicData.regression_testing:
		test_all_methods()

func _process(_delta: float) -> void:
	if !BasicData.regression_testing:
		test_all_methods()
		if exiting:
			get_tree().quit()

func test_all_methods() -> void:
	# Find all available classes
	for name_of_class in BasicData.get_available_classes():
		if debug_enabled:
			print("\n#################### " + name_of_class + " ####################")
		var object: Object = ClassDB.instance(name_of_class)
		assert(object != null, "Object must be instantable")
		if add_to_tree:
			if object is Node:
				add_child(object)
		# Find all available methods
		var method_list: Array = ClassDB.class_get_method_list(name_of_class, !use_parent_methods)
		# Remove excluded methods
		BasicData.remove_disabled_methods(method_list, BasicData.disabled_methods)
		for _i in range(1):
			for method_data in method_list:
				if !BasicData.is_method_executable(method_data):
					continue
				var arguments: Array = ParseArgumentType.create_arguments(method_data, name_of_class, debug_enabled)
				if debug_enabled:
					var print_string: String = "GDSCRIPT CODE:     "
					if (
						ClassDB.is_parent_class(name_of_class, "Object")
						&& !ClassDB.is_parent_class(name_of_class, "Node")
						&& !ClassDB.is_parent_class(name_of_class, "Reference")
						&& !ClassDB.class_has_method(name_of_class, "new")
					):
						print_string += "ClassDB.instance(\"" + name_of_class + "\")." + method_data["name"] + "("
					else:
						print_string += name_of_class.trim_prefix("_") + ".new()." + method_data["name"] + "("
					for i in arguments.size():
						print_string += ParseArgumentType.get_string_to_create_object(arguments[i])
						if i != arguments.size() - 1:
							print_string += ", "
					print_string += ")"
					print(print_string)
				object.callv(method_data["name"], arguments)
				for argument in arguments:
					if argument is Node:
						argument.queue_free()
					elif argument is Object && !(argument is Reference):
						argument.free()
				if always_create_new_object:
					if object is Node:
						object.queue_free()
					elif object is Object && !(object is Reference):
						object.free()
					object = ClassDB.instance(name_of_class)
					if add_to_tree:
						if object is Node:
							add_child(object)
		if object is Node:
			object.queue_free()
		elif object is Object && !(object is Reference):
			object.free()
