extends Node

class ArgumentData:
	var name: String
	var type: String
	var value: String
	var is_object: bool = false
	# Needs to be removed with .queue_free()
	var is_only_node: bool = false
	# Can be freed with free()
	var is_only_object: bool = false
	# Doesn't need to be freed
	var is_only_reference: bool = false

func create_gdscript_arguments(arguments: Array) -> Array:
	var argument_array: Array = []
	var counter = 0
	for argument in arguments:
		counter += 1
		var sa: ArgumentData = ArgumentData.new()
		sa.name = "variable" + str(counter)
		match argument["type"]:
			# TYPE_NIL means VARIANT not null
			TYPE_NIL:
				sa.type = "Variant"
				sa.value = "false"
			TYPE_AABB:
				sa.type = "AABB"
				sa.value = ValueCreator.get_aabb_string()
			TYPE_ARRAY:
				sa.type = "Array"
				sa.value = "[]"
			TYPE_BASIS:
				sa.type = "Basis"
				sa.value = ValueCreator.get_basis_string()
			TYPE_BOOL:
				sa.type = "bool"
				sa.value = ValueCreator.get_bool_string().to_lower()
			TYPE_COLOR:
				sa.type = "Color"
				sa.value = ValueCreator.get_color_string()
			TYPE_COLOR_ARRAY:
				sa.type = "PoolColorArray"
				sa.value = "PoolColorArray([])"
			TYPE_DICTIONARY:
				sa.type = "Dictionary"
				sa.value = "{}" # TODO: Use ValueCreator
			TYPE_INT:
				sa.type = "int"
				sa.value = ValueCreator.get_int_string()
			TYPE_INT_ARRAY:
				sa.type = "PoolIntArray"
				sa.value = "PoolIntArray([])"
			TYPE_NODE_PATH:
				sa.type = "NodePath"
				sa.value = "NodePath(\".\")"
			TYPE_OBJECT:
				sa.type = ValueCreator.get_object_string(argument["class_name"])
				sa.value = sa.type + ".new()"
				sa.is_object = true
				if ClassDB.is_parent_class(sa.type, "Node"):
					sa.is_only_node = true
				elif ClassDB.is_parent_class(sa.type, "Reference"):
					sa.is_only_reference = true
				else:
					sa.is_only_object = true
			TYPE_PLANE:
				sa.type = "Plane"
				sa.value = ValueCreator.get_plane_string()
			TYPE_QUAT:
				sa.type = "Quat"
				sa.value = ValueCreator.get_quat_string()
			TYPE_RAW_ARRAY:
				sa.type = "PoolByteArray"
				sa.value = "PoolByteArray([])"
			TYPE_REAL:
				sa.type = "float"
				sa.value = ValueCreator.get_float_string()
			TYPE_REAL_ARRAY:
				sa.type = "PoolRealArray"
				sa.value = "PoolRealArray([])"
			TYPE_RECT2:
				sa.type = "Rect2"
				sa.value = ValueCreator.get_rect2_string()
			TYPE_RID:
				sa.type = "RID"
				sa.value = "RID()"
			TYPE_STRING:
				sa.type = "String"
				sa.value = ValueCreator.get_string_string()
			TYPE_STRING_ARRAY:
				sa.type = "PoolStringArray"
				sa.value = "PoolStringArray([])"
			TYPE_TRANSFORM:
				sa.type = "Transform"
				sa.value = ValueCreator.get_transform_string()
			TYPE_TRANSFORM2D:
				sa.type = "Transform2D"
				sa.value = ValueCreator.get_transform2D_string()
			TYPE_VECTOR2:
				sa.type = "Vector2"
				sa.value = ValueCreator.get_vector2_string()
			TYPE_VECTOR2_ARRAY:
				sa.type = "PoolVector2Array"
				sa.value = "PoolVector2Array([])"
			TYPE_VECTOR3:
				sa.type = "Vector3"
				sa.value = ValueCreator.get_vector3_string()
			TYPE_VECTOR3_ARRAY:
				sa.type = "PoolVector3Array"
				sa.value = "PoolVector3Array([])"
			_:
				assert(false, "Missing type, needs to be added to project")
		argument_array.append(sa)
	return argument_array

func create_arguments(method_data: Dictionary, name_of_class: String, debug_enabled: bool = false) -> Array:
	var arguments: Array = []
	for argument in method_data["args"]:
		match argument.type:
			# TYPE_NIL means VARIANT not null
			TYPE_NIL:
				if ValueCreator.random == false:
					arguments.push_back(false)
				else:
					if randi() % 3:
						arguments.push_back(ValueCreator.get_array())
					elif randi() % 3:
						arguments.push_back(ValueCreator.get_object("Object"))
					elif randi() % 3:
						arguments.push_back(ValueCreator.get_dictionary())
					elif randi() % 3:
						arguments.push_back(ValueCreator.get_string())
					elif randi() % 3:
						arguments.push_back(ValueCreator.get_int())
					else:
						arguments.push_back(ValueCreator.get_basis())
			TYPE_AABB:
				arguments.push_back(ValueCreator.get_aabb())
			TYPE_ARRAY:
				arguments.push_back(ValueCreator.get_array())
			TYPE_BASIS:
				arguments.push_back(ValueCreator.get_basis())
			TYPE_BOOL:
				arguments.push_back(ValueCreator.get_bool())
			TYPE_COLOR:
				arguments.push_back(ValueCreator.get_color())
			TYPE_COLOR_ARRAY:
				arguments.push_back(ValueCreator.get_pool_color_array())
			TYPE_DICTIONARY:
				arguments.push_back(ValueCreator.get_dictionary())
			TYPE_INT:
				arguments.push_back(ValueCreator.get_int())
			TYPE_INT_ARRAY:
				arguments.push_back(ValueCreator.get_pool_int_array())
			TYPE_NODE_PATH:
				arguments.push_back(ValueCreator.get_nodepath())
			TYPE_OBJECT:
				if ValueCreator.random && randi() % 2:
					arguments.push_back(null)
				else:
					var obj: Object = ValueCreator.get_object(argument["class_name"])
					arguments.push_back(obj)
					assert(obj != null, "Failed to create an object of type " + argument["class_name"])
			TYPE_PLANE:
				arguments.push_back(ValueCreator.get_plane())
			TYPE_QUAT:
				arguments.push_back(ValueCreator.get_quat())
			TYPE_RAW_ARRAY:
				arguments.push_back(ValueCreator.get_pool_byte_array())
			TYPE_REAL:
				arguments.push_back(ValueCreator.get_float())
			TYPE_REAL_ARRAY:
				arguments.push_back(ValueCreator.get_pool_real_array())
			TYPE_RECT2:
				arguments.push_back(ValueCreator.get_rect2())
			TYPE_RID:
				arguments.push_back(RID())
			TYPE_STRING:
				arguments.push_back(ValueCreator.get_string())
			TYPE_STRING_ARRAY:
				arguments.push_back(ValueCreator.get_pool_string_array())
			TYPE_TRANSFORM:
				arguments.push_back(ValueCreator.get_transform())
			TYPE_TRANSFORM2D:
				arguments.push_back(ValueCreator.get_transform2D())
			TYPE_VECTOR2:
				arguments.push_back(ValueCreator.get_vector2())
			TYPE_VECTOR2_ARRAY:
				arguments.push_back(ValueCreator.get_pool_vector2_array())
			TYPE_VECTOR3:
				arguments.push_back(ValueCreator.get_vector3())
			TYPE_VECTOR3_ARRAY:
				arguments.push_back(ValueCreator.get_pool_vector3_array())
			_:
				assert(false, "Missing type, needs to be added to project")
	if debug_enabled:
		print("\n" + name_of_class + "." + method_data["name"] + " --- executing with " + str(arguments.size()) + " parameters " + str(arguments))
	return arguments

func get_string_to_create_object(data) -> String:
	if data == null:
		return "null"
	var return_string: String = ""
	match typeof(data):
		# TYPE_NIL means VARIANT not null
		TYPE_NIL:
			assert("false", "Is this even possible?")
		TYPE_AABB:
			return_string = "AABB("
			return_string += get_string_to_create_object(data.position)
			return_string += ", "
			return_string += get_string_to_create_object(data.size)
			return_string += ")"
		TYPE_ARRAY:
			return_string = "Array(["
			for i in data.size():
				return_string += get_string_to_create_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_BASIS:
			return_string = "Basis("
			return_string += get_string_to_create_object(data.x)
			return_string += ", "
			return_string += get_string_to_create_object(data.y)
			return_string += ", "
			return_string += get_string_to_create_object(data.z)
			return_string += ")"
		TYPE_BOOL:
			if data == true:
				return_string = "true"
			else:
				return_string = "false"
		TYPE_COLOR:
			return_string = "Color("
			return_string += get_string_to_create_object(data.r)
			return_string += ", "
			return_string += get_string_to_create_object(data.g)
			return_string += ", "
			return_string += get_string_to_create_object(data.b)
			return_string += ", "
			return_string += get_string_to_create_object(data.a)
			return_string += ")"
		TYPE_COLOR_ARRAY:
			return_string = "PoolColorArray(["
			for i in data.size():
				return_string += get_string_to_create_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_DICTIONARY:
			return_string = "{"
			for i in data.size():
				return_string += get_string_to_create_object(data.keys()[i])
				return_string += " : "
				return_string += get_string_to_create_object(data.values()[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "}"
		TYPE_INT:
			return_string = str(data)
		TYPE_INT_ARRAY:
			return_string = "PoolIntArray(["
			for i in data.size():
				return_string += get_string_to_create_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_NODE_PATH:
			return_string = "NodePath("
			return_string += get_string_to_create_object(str(data))
			return_string += ")"
		TYPE_OBJECT:
			if data == null:
				return_string = "null"
			else:
				var name_of_class: String = data.get_class()
				if (
					ClassDB.is_parent_class(name_of_class, "Object")
					&& !ClassDB.is_parent_class(name_of_class, "Node")
					&& !ClassDB.is_parent_class(name_of_class, "Reference")
					&& !ClassDB.class_has_method(name_of_class, "new")
				):
					return_string += "ClassDB.instance(\"" + name_of_class + "\")"
				else:
					return_string = name_of_class.trim_prefix("_")
					return_string += ".new()"
		TYPE_PLANE:
			return_string = "Plane("
			return_string += get_string_to_create_object(data.x)
			return_string += ", "
			return_string += get_string_to_create_object(data.y)
			return_string += ", "
			return_string += get_string_to_create_object(data.z)
			return_string += ", "
			return_string += get_string_to_create_object(data.d)
			return_string += ")"
		TYPE_QUAT:
			return_string = "Quat("
			return_string += get_string_to_create_object(data.x)
			return_string += ", "
			return_string += get_string_to_create_object(data.y)
			return_string += ", "
			return_string += get_string_to_create_object(data.z)
			return_string += ", "
			return_string += get_string_to_create_object(data.w)
			return_string += ")"
		TYPE_RAW_ARRAY:
			return_string = "PoolByteArray(["
			for i in data.size():
				return_string += get_string_to_create_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_REAL:
			return_string = str(data)
		TYPE_REAL_ARRAY:
			return_string = "PoolRealArray(["
			for i in data.size():
				return_string += get_string_to_create_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_RECT2:
			return_string = "Rect2("
			return_string += get_string_to_create_object(data.position)
			return_string += ", "
			return_string += get_string_to_create_object(data.size)
			return_string += ")"
		TYPE_RID:
			return_string = "RID()"
		TYPE_STRING:
			return_string = "\"" + data + "\""
		TYPE_STRING_ARRAY:
			return_string = "PoolStringArray(["
			for i in data.size():
				return_string += get_string_to_create_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_TRANSFORM:
			return_string = "Transform("
			return_string += get_string_to_create_object(data.basis)
			return_string += ", "
			return_string += get_string_to_create_object(data.origin)
			return_string += ")"
		TYPE_TRANSFORM2D:
			return_string = "Transform2D("
			return_string += get_string_to_create_object(data.x)
			return_string += ", "
			return_string += get_string_to_create_object(data.y)
			return_string += ", "
			return_string += get_string_to_create_object(data.origin)
			return_string += ")"
		TYPE_VECTOR2:
			return_string = "Vector2("
			return_string += get_string_to_create_object(data.x)
			return_string += ", "
			return_string += get_string_to_create_object(data.y)
			return_string += ")"
		TYPE_VECTOR2_ARRAY:
			return_string = "PoolVector2Array(["
			for i in data.size():
				return_string += get_string_to_create_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		TYPE_VECTOR3:
			return_string = "Vector3("
			return_string += get_string_to_create_object(data.x)
			return_string += ", "
			return_string += get_string_to_create_object(data.y)
			return_string += ", "
			return_string += get_string_to_create_object(data.z)
			return_string += ")"
		TYPE_VECTOR3_ARRAY:
			return_string = "PoolVector3Array(["
			for i in data.size():
				return_string += get_string_to_create_object(data[i])
				if i != data.size() - 1:
					return_string += ", "
			return_string += "])"
		_:
			assert(false, "Missing type, needs to be added to project")
	return return_string
