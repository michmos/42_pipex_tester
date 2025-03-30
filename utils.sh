
BOLD="\033[1m"
BLACK="\033[30;1m"
RED="\033[31;1m"
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
MAGENTA="\033[35;1m"
RESET="\033[0m"

DELIMITER="------------------------------------------------------------------------------------------------------------------------"

set_flags () {
	if [ "$1" == --help ]; then print_help && exit 0; fi
	if [[ "$1" == "--show-valgrind" 	||  "$2" == "--show-valgrind" ]]; then SHOW_VALGRIND=1; else SHOW_VALGRIND=0; fi
	if [[ "$1" == "--hide-err-log"  	||  "$2" == "--hide-err-log" ]]; then HIDE_LOG=1; else HIDE_LOG=0; fi
	# check only one test
	if [[ "$1" == --test=* ]]; then
		TEST_NUM_ONLY="${1#--test=}"
	elif [[ "$2" == --test=* ]]; then
		TEST_NUM_ONLY="${2#--test=}"
	else
		TEST_NUM_ONLY=-1
	fi
}

print_help () {
	printf "${BOLD}%-20s %s${RESET}\n" "FLAG" "MEANING"
	printf "%-20s %s\n" "--hide-err-log" "hide detailed information on KOs"
	printf "%-20s %s\n" "--show-valgrind" "show detailed valgrind output"
	printf "%-20s %s\n" "--test=<test_num>" "run only the test number <test_num>"
}

print_arg_array() {
	local size=${#ARG_ARRAY[@]}

	for ((i=0; i<$size; i++)); do
		printf "\"%s\" " "${ARG_ARRAY[i]}"
	done
}

print_err_log () {
	if (( $(wc -c < "last_err_log.txt") != 0)); then
		printf "$RED$BOLD\nERRORS :($RESET\n"
		cat last_err_log.txt
	fi
}

print_test_case() {
	printf "${RED}%s\n" "$DELIMITER" 
	printf "TEST %i:\n${RESET}" ${TEST_NUM}

	printf "${BOLD}./pipex "
	print_arg_array

	printf "\n%s\n\n${RESET}" "${ARG_STR}"
}

print_header() {
	printf "${YELLOW}\n%s\n${RESET}" "$1"
}

tester_setup() {
	rm pipex

	# compiling
	make -C ${PIPEX_DIR} all
	make -C ${PIPEX_DIR} bonus
	printf "\n"
	cp ${PIPEX_DIR}/pipex ./ 2> /dev/null
	if [ -f "${PIPEX_DIR}/pipex" ] && [ -x "${PIPEX_DIR}/pipex" ];then
		printf "%-20s$GREEN%-8s$RESET\n" "compiling" "[OK]"
	else
		printf "%-20s$RED%-8s  \"pipex\" not found. Check that correct path is set in run.sh file$RESET\n\n" "compiling" "[KO]"; exit 1
	fi

	# norminette
	if type "norminette" > /dev/null 2>&1; then
		if norminette ${PIPEX_DIR} | grep 'Error!' > /dev/null; then
			printf "%-20s$RED%-8s$RESET\n" "norminette" "[KO]"
		else
			printf "%-20s$GREEN%-8s$RESET\n" "norminette" "[OK]"
		fi
	else
		printf "$RED$BOLD norminette not found $RESET"
	fi

	printf "\n\n$BOLD$MAGENTA%-90s%-8s%-8s%-8s%-8s\n$RESET" "TESTNAME" "OUT" "EXIT" "TIME" "LEAKS"

	exec 2> /dev/null
}
