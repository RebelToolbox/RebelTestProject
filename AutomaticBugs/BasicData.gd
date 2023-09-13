extends Node

# Set to true when doing regression testing.
var regression_testing: bool = true

# List of disabled methods for all classes
var disabled_methods: Array = [
	"get_packet", # TODO
	"_gui_input", # TODO: Probably missing cherrypick GH 47636
	"_input", # TODO
	"_unhandled_input", # TODO
	"_unhandled_key_input", # TODO
	"connect_to_signal", # TODO
	# Can be called without initialising: like Class.method, because
	# It may be a parent of other objects and children
	# Requires disabling child.method and all its children
	#"connect_to_signal", # GH 47572
	"_editor_settings_changed",# GH 45979
	"_submenu_timeout", # GH 45981
	"_thread_done", # GH 46000
	"generate", # GH 46001
	"_proximity_group_broadcast", # GH 46002
	"_direct_state_changed", # GH 46003
	"create_from", # GH 46004
	"create_from_blend_shape", # GH 46004
	"append_from", # GH 46004
	"_set_tile_data", # GH 46015
	"get", # GH 46019
	"instance_has", # GH 46020
	"get_var", # GH 46096
	"set_script", # GH 46120
	"getvar", # GH 46019
	"get_available_chars", # GH 46118
	"open_midi_inputs", # GH 46183
	"set_icon", # GH 46189
	"get_latin_keyboard_variant", # TODO: Memory Leak
	"set_editor_hint", # GH 46252
	"get_item_at_position", # TODO: Hard to find
	"set_probe_data", # GH 46570
	"_range_click_timeout", # GH 46648
	"get_indexed", # GH 46019
	"add_vertex", # GH 47066
	"create_client", # TODO: Strange memory leak
	"create_shape_owner", #47135
	"shape_owner_get_owner", #47135
	"get_bind_bone", # GH 47358
	"get_bind_name", # GH 47358
	"get_bind_pose", # GH 47358
	"propagate_notification", # TODO
	"notification", # TODO
	"add_sphere", 	# TODO: Spams the log when when i > 100
	"_update_inputs", # TODO: Spams the log with add_input
	"update_bitmask_region", # TODO: Spams the log when i~1000
	"set_enabled_inputs", # TODO
	"_update_sky", # TODO: Slow
	# Undo/Redo functions don't provide enough information about types of objects
	# May be due to vararg(variable size argument)
	"add_do_method", # TODO
	"add_undo_method", # TODO
	# Disable saving files and creating folders
	"pck_start",
	"save",
	"save_png",
	"save_to_wav",
	"save_to_file",
	"make_dir",
	"make_dir_recursive",
	"save_encrypted",
	"save_encrypted_pass",
	"save_exr",
	"dump_resources_to_file",
	"dump_memory_to_file",
	# Disable opening files
	"open",
	"open_encrypted",
	"open_encrypted_with_pass",
	"open_compressed",
	# Disable mouse warp
	"warp_mouse",
	"warp_mouse_position",
	# Disable OS functions
	"kill",
	"shell_open",
	"execute",
	"delay_usec",
	"delay_msec",
	# Blocking alert window that waits for user input
	"alert",
	# Blocking functions
	"wait_to_finish",
	"accept_stream",
	"connect_to_stream",
	"discover",
	"wait",
	"debug_bake",
	"bake",
	"_create", # TODO
	"set_gizmo", # TODO: Should be removed: Needs an object parameter that can't be instanced 
	# Spams the log
	"print_tree",
	"print_stray_nodes",
	"print_tree_pretty",
	"print_all_textures_by_size",
	"print_all_resources",
	"print_resources_in_use",
	# Do not call other functions
	"_call_function",
	"call",
	"call_deferred",
	"callv",
	# May be a bug in FuncRef, probably not needed
	"call_func", # TODO
	# Disable, because they add, mix and remove random nodes and objects
	"replace_by",
	"create_instance",
	"set_owner",
	"set_root_node",
	"instance",
	"init_ref",
	"reference",
	"unreference",
	"new",
	"duplicate",
	"queue_free",
	"free",
	"remove_and_skip",
	"remove_child",
	"move_child",
	"raise",
	"add_child",
	"add_child_below_node",
	"add_sibling",
]

# List of disabled classes
var disabled_classes: Array = [
	"_Thread",
	"_Semaphore",
	"_Mutex",
	"ProjectSettings", # Don't change project settings, because they can break the workflow
	"EditorSettings",
	"_OS", # TODO
	"GDScript", # TODO
	"PhysicsDirectSpaceState", # TODO
	"Physics2DDirectSpaceState", # TODO
	"PhysicsDirectBodyState", # TODO
	"Physics2DDirectBodyState", # TODO
	"BulletPhysicsDirectSpaceState", # TODO
	"InputDefault", # TODO
	"IP_Unix", # TODO
	"JNISingleton", # TODO
	"JavaClass",  # TODO: Returns Null when using JavaClass.new().get_class
]

# Check if method can be executed
func is_method_executable(method_data: Dictionary) -> bool:
	# Skip virtual or vararg functions
	if method_data["flags"] == method_data["flags"] | METHOD_FLAG_VIRTUAL:
		return false
	if method_data["flags"] == method_data["flags"] | 128: # TODO: New issue: add missing flag binding
		return false
	# Check arguments
	for arg in method_data["args"]:
		var name_of_class: String = arg["class_name"]
		if name_of_class.empty():
			continue
		if name_of_class in disabled_classes:
			return false
		if name_of_class.find("Server") != -1 && ClassDB.class_exists(name_of_class) && !ClassDB.is_parent_class(name_of_class,"Reference"):
			return false
		# Skip classes with Editor and SkinReference in the name
		if name_of_class.find("Editor") != -1 || name_of_class.find("SkinReference") != -1:
			return false
		# New types may cause a crash
		# Ignore unknown types
		var type: int = arg["type"]
		if !(type == TYPE_NIL ||
				type == TYPE_AABB ||
				type == TYPE_ARRAY ||
				type == TYPE_BASIS ||
				type == TYPE_BOOL ||
				type == TYPE_COLOR ||
				type == TYPE_COLOR_ARRAY ||
				type == TYPE_DICTIONARY ||
				type == TYPE_INT ||
				type == TYPE_INT_ARRAY ||
				type == TYPE_NODE_PATH ||
				type == TYPE_OBJECT ||
				type == TYPE_PLANE ||
				type == TYPE_QUAT ||
				type == TYPE_RAW_ARRAY ||
				type == TYPE_REAL ||
				type == TYPE_REAL_ARRAY ||
				type == TYPE_RECT2 ||
				type == TYPE_RID ||
				type == TYPE_STRING ||
				type == TYPE_TRANSFORM ||
				type == TYPE_TRANSFORM2D ||
				type == TYPE_VECTOR2 ||
				type == TYPE_VECTOR2_ARRAY ||
				type == TYPE_VECTOR3 ||
				type == TYPE_VECTOR3_ARRAY):
			print("Unknown type: ", type)
			return false
		if regression_testing:
			# If class doesn't exist it is probably a constant
			if !ClassDB.class_exists(name_of_class):
				continue
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "Reference"):
				return false
	return true

func remove_disabled_methods(method_list: Array, exceptions: Array) -> void:
	for exception in exceptions:
		var index: int = -1
		for method_index in range(method_list.size()):
			if method_list[method_index]["name"] == exception:
				index = method_index
				break
		if index != -1:
			method_list.remove(index)

func get_available_classes(must_be_instantable: bool = true) -> Array:
	var full_class_list: Array = Array(ClassDB.get_class_list())
	var classes: Array = []
	full_class_list.sort()
	var c = 0
	for name_of_class in full_class_list:
		if name_of_class in disabled_classes:
			continue
		if regression_testing:
			if !ClassDB.is_parent_class(name_of_class, "Node") && !ClassDB.is_parent_class(name_of_class, "Reference"):
				continue
		if name_of_class.find("Server") != -1 && !ClassDB.is_parent_class(name_of_class,"Reference"):
			continue
		if name_of_class.find("Editor") != -1 && regression_testing:
			continue
		if !must_be_instantable || ClassDB.can_instance(name_of_class):
			classes.push_back(name_of_class)
			c+= 1
	print(str(c) + " choosen classes from all " + str(full_class_list.size()) + " classes.")
	return classes
