#!/bin/bash

source test.sh
source utils.sh

# -- SETUP ------------------------------------------------------------------------------#
PIPEX_DIR=$(dirname "$0")/../ # ADJUST PATH TO PIPEX DIRECTORY IF NECESSARY
TIMEOUT=7
rm -rf outfiles/*
echo -n > last_err_log.txt

tester_setup


# -- TEST -------------------------------------------------------------------------------#
print_header "BASIC CHECKS"
test "infiles/basic.txt" "cat -e" "cat -e" "outfiles/outfile"
test "infiles/basic.txt" "ls -la" "cat -e" "outfiles/outfile"
test "infiles/basic.txt" "ls -l -a" "cat -e -n" "outfiles/outfile"
test "infiles/basic.txt" "grep -A5 is" "cat -e" "outfiles/nonexistingfile"
test "infiles/empty.txt" "grep nonexistingword" "cat -e" "outfiles/outfile"
test "infiles/basic.txt" "sleep 3" "ls" "outfiles/outfile"

print_header "ERROR CHECKING"
# unvalid input file
test "nonexistingfile" "cat -e" "cat -e" "outfiles/outfile"
chmod 000 infiles/basic.txt
	test "infiles/basic.txt" "cat -e" "cat -e" "outfiles/outfile"
chmod 777 infiles/basic.txt
# wrong argument
test "infiles/basic.txt" "nonexistingcommand" "cat -e" "outfiles/outfile"
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
if [ "$1" != --hide-errors ]; then print_err_log; fi