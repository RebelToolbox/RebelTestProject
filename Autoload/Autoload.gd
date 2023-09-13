extends Node

const PRINT_TIME_INTERVAL: int = 5000
const screen_size = Vector2(1024, 600)
const test_scenes: Array = [
	"res://CreatingAllThings/CreatingAllThings.tscn",
	"res://Nodes/Nodes.tscn",
	"res://Physics/2D/Physics2D.tscn",
	"res://Physics/3D/Physics3D.tscn",
	"res://ReparentingDeleting/ReparentingDeleting.tscn",
	"res://AutomaticBugs/FunctionExecutor.tscn",
]

# Total test time in miliseconds.
# Default is 25 seconds.
var total_test_time: int = 25 * 1000
var scene_test_time: int = -1
var next_print_time: int = PRINT_TIME_INTERVAL
var all_tests_run: bool = false
var time_object: Object
var start_time: int
var last_time: int

func _init():
	if ClassDB.class_exists("_Time"):
		time_object = ClassDB.instance("_Time")
	elif ClassDB.class_exists("Time"):
		time_object = ClassDB.instance("_Time")
	else:
		time_object = ClassDB.instance("_OS")
	start_time = time_object.get_ticks_msec()
	# Check command line arguments for user defined total test time.
	for argument in OS.get_cmdline_args():
		# Ignore all non numeric arguments.
		if argument.is_valid_float():
			total_test_time = int(argument.to_float() * 1000)
			print("Total test time set to: ", str(total_test_time / 1000.0), " seconds")
			# Ignore all other arguments
			break
	scene_test_time = total_test_time / (test_scenes.size())

func _process(delta: float) -> void:
	var current_run_time: int = time_object.get_ticks_msec() - start_time
	# Using a while loop instead of an if loop allows the test time to be properly updated.
	while current_run_time > next_print_time:
		print("Total test running time: ", str(int(next_print_time / 1000), " seconds"))
		next_print_time += PRINT_TIME_INTERVAL
	if current_run_time > total_test_time && all_tests_run:
		print("All tests complete!")
		print("Total test time: ", str(current_run_time / 1000), " seconds")
		get_tree().quit()

func _exit_tree() -> void:
	time_object.free()
