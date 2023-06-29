# Rebel Test Project
A Rebel project used to find regressions in [Rebel Engine](https://github.com/RebelToolbox/RebelEngine).

This project was forked from the [Godot regression test project v3.4](https://github.com/godotengine/regression-test-project/tree/3.4), which was used to do regression testing against [Godot 3.4.5](https://github.com/godotengine/godot/tree/3.4.5-stable) from which Rebel Engine was forked.

## Basic Information
This project contains a number of test scenes and a default `Start.tscn` scene that opens all the other scenes. The list of test scenes can be found in the `Autoload.gd` file. Comment out selected lines in the `test_scenes` `Array` to choose which scenes will run.

![Autoload gd](https://github.com/RebelToolbox/RebelTestProject/assets/9253928/30ad7475-cacf-4388-975a-a53e8133a75b)

The project runs for a time-limited default 25s. It is possible to change how long the project is allowed to run. Either change the `total_test_time` variable, or, when running from the command line, append the number of seconds as an argument to the Rebel Engine exectuable. Each test scene is opened in turn and allowed to run for a equal fraction of the total test time.

This project is designed to run as part of CI with a version of Rebel Engine compiled with Address and Undefined sanitizers (`scons use_asan=yes use_ubsan=yes`). Without these options it won't always be possible to detect the bug or get a detailed backtrace.

## Finding a malfunctioning scene

### Logs
The quickest way to find the problem scene is by reviewing the logs. If you come across something like this:
```
Changed scene to res://Physics/2D/Physics2D.tscn
Total test running time: 10 seconds
Changed scene to res://Physics/3D/Physics3D.tscn
##### CRASH #####
Program crashed with signal ...
```
This indicates 2 potentially broken scenes:
- `Physics3D.tscn`: crash occured when scene was opened
- `Physics2D.tscn`: crash occured when scene was closed

### Manual Testing
Open the project in the editor and run each scene individually.

## "Safe" fuzzer
A scene that often causes problems is the `FunctionExecutor.tscn` scene. This scene is known as a fuzzer, but the option to run it with random argument values has been removed: the arguments are identical every time it is run. When Rebel Engine crashes while running the `FunctionExecutor.tscn` scene, the logs will usually contain something like this:
```
#################### LineEdit ####################

LineEdit._text_changed --- executing with 0 parameters []
GDSCRIPT CODE:     LineEdit.new()._text_changed()

LineEdit._toggle_draw_caret --- executing with 0 parameters []
GDSCRIPT CODE:     LineEdit.new()._toggle_draw_caret()

LineEdit.set_align --- executing with 1 parameters [100]
GDSCRIPT CODE:     LineEdit.new().set_align(100)
ERROR: set_align: Index (int)p_align = 100 is out of bounds (4 = 4).
   At: scene/gui/line_edit.cpp:592.
scene/resources/line_edit.cpp:186:2: runtime error: member access within null pointer of type 'struct LineEdit'
handle_crash: Program crashed with signal 11
Dumping the backtrace. Please include this when reporting the bug on https://github.com/RebelToolbox/RebelEngine/issues
[1] bin/rebel.linuxbsd.tools.64s() [0x1e697d8] (/home/runner/work/rebel/rebel/platform/linuxbsd/crash_handler_linuxbsd.cpp:54)
[2] /lib/x86_64-linux-gnu/libc.so.6(+0x46210) [0x7fd1ca5b0210] (??:0)
```
The first line shows what class was being tested
```
#################### LineEdit ####################
```
The line just before the `ERROR` line shows what fuction and parameters were being used
```
GDSCRIPT CODE:     LineEdit.new().set_align(100)
```
The `ERROR` line (hopefully) shows why the error occured
```
ERROR: set_align: Index (int)p_align = 100 is out of bounds (4 = 4).
```
The line after the `ERROR` line shows where the error occured
```
   At: scene/gui/line_edit.cpp:592.
```
The following lines will show the crash log which can provide additional information.

## Nodes
The `Nodes.tscn` scene simply adds and removes all available nodes.
It is used to catch obvious and easy to reproduce bugs early.

## Reparenting and Deleting
The `ReparentingDeleting.tscn` scene is a more advanced variation of the `Nodes.tscn` scene. It randomly adds, removes and moves nodes within the scene. It sometimes finds bugs that are otherwise hard to detect.

## Other Tests
Scenes like `Physics2D.tscn` are normal scenes focussing an specific types of nodes.

![Physics2D](https://github.com/RebelToolbox/RebelTestProject/assets/9253928/df8c0d2a-fec4-4355-aeab-05a07d31e4ed)

## Seizure Warning
This project uses a lot of functions from each type of node. The screen may flicker, and images and objects may change colour and size randomly. This may potentially trigger seizures for people with photosensitive epilepsy. User discretion is advised.

## Problems with the project
Since Rebel Engine CI relies on this project, updates to Rebel Engine may cause the Rebel Engine CI to fail. Therefore, this project may need to be updated before a Rebel Engine Pull Request can be merged. In that case, please submit a Pull Request that fixes this project and references the Rebel Engine Pull Request.
