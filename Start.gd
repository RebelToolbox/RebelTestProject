extends Control

# Number of instances of each test scene to load simultaneously
# 1 is sufficient for CI tests
# Increase for stress testing
const NUMBER_OF_INSTANCES: int = 1

var test_index: int = 0
var change_times: Array = []

func _ready():
	for index in Autoload.test_scenes.size() + 1:
		change_times.append(Autoload.time_object.get_ticks_msec() + index * Autoload.scene_test_time)

func _process(_delta):
	if test_index < change_times.size() && Autoload.time_object.get_ticks_msec() > change_times[test_index]:
		for child in get_children():
			child.queue_free()
		if test_index < Autoload.test_scenes.size():
			print("Loading test scene: " + Autoload.test_scenes[test_index])
			for _i in range(NUMBER_OF_INSTANCES):
				var scene = load(Autoload.test_scenes[test_index])
				if (scene == null):
					print("ERROR: Failed to load test scene: " + Autoload.test_scenes[test_index])
				else:
					add_child(scene.instance())
		else:
			Autoload.all_tests_run = true
		test_index += 1
