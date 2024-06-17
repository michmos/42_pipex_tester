#!/bin/bash

source test.sh
source utils.sh
if [ "$1" == --help ]; then print_help && exit 0; fi
if [ "$1" == --show-valgrind ]; then SHOW_VALGRIND=1; else SHOW_VALGRIND=0; fi
if [ "$1" == --hide-err-log ]; then HIDE_LOG=1; else HIDE_LOG=0; fi

# -- SETUP ------------------------------------------------------------------------------#
# ADJUST PATH TO PIPEX DIRECTORY IF NECESSARY (-> IF ITS NOT THE PARENT DIRCTORY)
PIPEX_DIR=$(dirname "$0")/../

TIMEOUT=7
rm -rf outfiles
mkdir outfiles
echo -n > last_err_log.txt

tester_setup

# -- TEST -------------------------------------------------------------------------------#
print_header "BASIC CHECKS"
test "infiles/basic.txt" "cat -e" "cat -e" "outfiles/outfile"
test "infiles/basic.txt" "ls -la" "cat -e" "outfiles/outfile"
test "infiles/basic.txt" "ls -l -a" "cat -e -n" "outfiles/outfile"
test "infiles/basic.txt" "ls -l -a -f" "cat -e -n" "outfiles/outfile"
test "infiles/basic.txt" "ls -laf" "cat -e -n" "outfiles/outfile"
test "infiles/basic.txt" "grep -A5 is" "cat -e" "outfiles/nonexistingfile"
test "infiles/basic.txt" "cat -e" "grep nonexistingword" "outfiles/nonexistingfile"
test "infiles/empty.txt" "grep nonexistingword" "cat -e" "outfiles/outfile"
test "infiles/basic.txt" "sleep 3" "ls" "outfiles/outfile"
test "infiles/big_text.txt" "cat" "head -2" "outfiles/outfile"

print_header "ERROR CHECKING"
# invalid input file
test "nonexistingfile" "cat -e" "ls" "outfiles/outfile"
test "nonexistingfile" "cat" "sleep 3" "outfiles/outfile"
touch infiles/infile_without_permissions
chmod 000 infiles/infile_without_permissions
	test "infiles/infile_without_permissions" "cat -e" "cat -e" "outfiles/outfile"
# ouput file without permissions
touch outfiles/outfile_without_permissions
chmod 000 outfiles/outfile_without_permissions
	test "infiles/basic.txt" "cat -e" "cat -e" "outfiles/outfile_without_permissions"
	test "infiles/basic.txt" "sleep 3" "cat -e" "outfiles/outfile_without_permissions"
	test "nonexistingfile" "cat -e" "cat -e" "outfiles/outfile_without_permissions"
# wrong argument
test "infiles/basic.txt" "nonexistingcommand" "cat -e" "outfiles/outfile"
test "infiles/basic.txt" "cat -e" "nonexistingcommand" "outfiles/outfile"
test "infiles/basic.txt" "cat -e" "cat -nonexistingflag" "outfiles/outfile"
LEAKS_ONLY=1 # checks only for Leaks (FATAL ERRORS like segfaults are always checked)
	# not enough arguments
	test
	test ""
	test "infiles/basic.txt" "cat -e" "outfiles/outfile"
	# empty string
	test "" "cat -e" "cat -e" "outfiles/outfile"
	test "infiles/basic.txt" "" "cat -e" "outfiles/outfile"
	test "infiles/basic.txt" "cat -e" "" "outfiles/outfile"
LEAKS_ONLY=0

print_header "BONUS"
test "infiles/basic.txt" "cat -e" "cat -e" "cat -e" "outfiles/outfile"
# 100 times cat -e
test "infiles/basic.txt" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "cat -e" "outfiles/outfile"
HERE_DOC=$'Hello\nHello\nHello\nEOF\n'
test "here_doc" "EOF" "cat -e" "cat -e" "outfiles/outfile"


# -- ERROR_OUTPUT -----------------------------------------------------------------------#
if (( ${HIDE_LOG} == 0 )); then print_err_log; fi
