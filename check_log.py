#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Output log file checker

The CI tests should fail if the test project or sanitizers identify new issues.
However, the CI tests should not fail for pre-existing, unresolved issues.
Therefore, to enable the CI tests to pass until the pre-existing, unresolved issues are addressed,
the CI tests ignore the project and sanitizer error return values.
This script scans the captured standard and error output for specific entries, and
if errors are found, returns an error value, which causes the CI test to fail.
"""

import sys

if len(sys.argv) < 2:
    print("Please provide the filename of the log file to check as an argument.")
    sys.exit(1)

filename = sys.argv[1]
logfile = open(filename.strip(), "r")
log = logfile.read()

# "ERROR: AddressSanitizer:" occurs when there is an invalid read or write.
# This should be considered a critical bug.
# An issue should be raised and the bug fixed as soon as possible.
if log.find("ERROR: AddressSanitizer:") != -1:
    print("CRITICAL ERROR: Invalid use of memory found.")
    sys.exit(1)

# Detect if the program crashed
if (
    log.find("Program crashed with signal") != -1
    or log.find("Dumping the backtrace") != -1
    or log.find("Segmentation fault (core dumped)") != -1
):
    print("FATAL ERROR: Rebel Engine crashed.")
    sys.exit(1)

# Finding memory leaks in Rebel Engine is quite difficult.
# We also need to consider leaks in external libraries.
# External libraries usually don't have debugging symbols.
# Therefore, the leak report usually has only 2/3 lines.
# Searching for "#4 0x" should correctly detect the vast majority of memory leaks.
if log.find("ERROR: LeakSanitizer:") != -1:
    if log.find("#4 0x") != -1:
        print("ERROR: Memory leak found")
        sys.exit(1)

# Rebel Engine may detect leaking nodes or resources and remove them.
# This should also be considered a bug.
# An issue should be raised and the bug fixed as soon as possible.
if log.find("ObjectDB instances leaked at exit") != -1:
    print("ERROR: Rebel Engine memory leak found")
    sys.exit(1)

# No errors detected
sys.exit(0)
