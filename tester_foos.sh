
BOLD="\033[1m"
BLACK="\033[30;1m"
RED="\033[31;1m"
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
MAGENTA="\033[35;1m"
RESET="\033[0m"

DELIMITER="------------------------------------------------------------------------------------------------------------------------"

PIPEX_DIR=""

TEST_NUM=1
ERROR_FLAG=0
LEAKS_ONLY=0

HERE_DOC=''
HERE_DOC_FLAG=0

OUTPUTFILE=""
OUTPUTFILE1=""

ARG_ARRAY=""
ARG_STR=""

test () {
	ARG_ARRAY=("$@")
	OUTPUTFILE="${ARG_ARRAY[-1]}"
	OUTPUTFILE1="${OUTPUTFILE}_tester"

	ERROR_FLAG=0
	if [[ ${ARG_ARRAY[0]} == "here_doc" ]]; then
		HERE_DOC_FLAG=1
	else
		HERE_DOC_FLAG=0
	fi

	printf "#%2i: %-85.83s" "${TEST_NUM}" "$(print_arg_array)"
	if (( ${#ARG_ARRAY[@]} < 4 )) && (( LEAKS_ONLY == 0 )); then
		printf "${RED}NOT ENOUGH ARGS FOR COMPARISON. ACTIVATE LEAKS_ONLY OR ADD ARGS\n${RESET}"; return
	fi

	# construct command line for og piping
	if (( HERE_DOC_FLAG == 1 )); then
		ARG_STR="${ARG_ARRAY[2]} << ${ARG_ARRAY[1]}"
		for ((i=3; i<${#ARG_ARRAY[@]} - 1; i++));do
			ARG_STR+=" | "${ARG_ARRAY[i]}""
		done
		ARG_STR+=" >> ${OUTPUTFILE1}"
	else
		ARG_STR="< ${ARG_ARRAY[0]} ${ARG_ARRAY[1]}"
		for (( i=2; i<${#ARG_ARRAY[@]} - 1; i++ ));do
			ARG_STR+=" | "${ARG_ARRAY[i]}""
		done
		ARG_STR+=" > ${OUTPUTFILE1}"
	fi

	# make sure outputfiles are identical before testing and have necessary permissions
	if [ -f "$OUTPUTFILE1" ]; then
		rm -rf $OUTPUTFILE1
	fi
	if (( LEAKS_ONLY == 0 )) && [ -f "$OUTPUTFILE" ]; then
		# read permissions are necessary for cp and diff operations
		chmod u+r $OUTPUTFILE
		cp $OUTPUTFILE $OUTPUTFILE1
	fi

	# execute mine and get time and exit status
	SECONDS=0
	timeout $TIMEOUT ./pipex "${ARG_ARRAY[@]}" < <(echo "${HERE_DOC}") &
	local pid=$!
	wait $pid
	local exit_status_my=$?
	local time_my=$SECONDS
	if (( exit_status_my == 124 )); then
		printf "${RED}---------- TIMEOUT ----------\n${RESET}"
		if ps -p $pid > /dev/null; then kill $pid; fi
		return
	fi

	# execute og and get time and exit status
	SECONDS=0
	eval "$ARG_STR
${HERE_DOC}" 2> /dev/null
	local exit_status_og=$?
	local time_og=$SECONDS

	# print results
	if (( exit_status_my > 128 )); then printf "${RED}------- FATAL ERROR -------\n${RESET}"; return; fi
	if (( LEAKS_ONLY == 0 )); then
		if [[ ! -f $OUTPUTFILE ]]; then printf "${RED}DIDN'T CREATE OUTPUTFILE${RESET}\n"; return; fi
		result_output
		result_ex_stat "${exit_status_my}" "${exit_status_og}"
		result_time ${time_my} ${time_og}
	else
		printf "%24s" " "
	fi
	result_leaks

	TEST_NUM=$(( TEST_NUM + 1 ))
}

result_output() {
	local temp_file=$(mktemp)
	if diff -y "$OUTPUTFILE" "$OUTPUTFILE1" > ${temp_file}; then
		printf "${GREEN}%-8s${RESET}" "[OK]"
	else
		if (( ${ERROR_FLAG} == 0 )); then print_test_case >> last_err_log.txt; fi
		ERROR_FLAG=1
		cat ${temp_file} >> last_err_log.txt
		printf "\n" >> last_err_log.txt
		printf "${RED}%-8s${RESET}" "[KO]"
	fi
	rm "${temp_file}"
}

result_ex_stat() {
	if [ "$1" == "$2" ]; then
		printf "${GREEN}%-8s${RESET}" "[OK]"
	else
		if (( ${ERROR_FLAG} == 0 )); then print_test_case >> last_err_log.txt; fi
		ERROR_FLAG=1
		printf "${RED}%-8s${RESET}" "[KO]"
		printf "Your exit status: %s\n" $1 >> last_err_log.txt
		printf "Orig exit status: %s\n\n" $2 >> last_err_log.txt
	fi
}

result_time() {
	if (( $1 < $2 + 1 )) && (( $1 > $2 - 1 )); then
		printf "${GREEN}%-8s${RESET}" "[OK]"
	else
		if (( ${ERROR_FLAG} == 0 )); then print_test_case >> last_err_log.txt; fi
		ERROR_FLAG=1
		printf "${RED}%-8s${RESET}" "[KO]"
		printf "Your execution time: %s\n" $1 >> last_err_log.txt
		printf "Orig execution time: %s\n\n" $2 >> last_err_log.txt
	fi
}

result_leaks() {
	local temp_file=$(mktemp)
	eval "valgrind --log-file=${temp_file} --leak-check=full --errors-for-leak-kinds=all --error-exitcode=42 ./pipex "${ARG_ARRAY[@]}" < <(echo ${HERE_DOC})"
	local exit_status=$?
	if ((exit_status != 42)); then
		printf "${GREEN}%-8s${RESET}\n" "[OK]"
	else
		if (( ${ERROR_FLAG} == 0 )); then print_test_case >> last_err_log.txt; fi
		ERROR_FLAG=1
		printf "${RED}%-8s${RESET}\n" "[KO]"
		cat "${temp_file}" | grep 'HEAP SUMMARY' -A9 --max-count=1 >> last_err_log.txt
		printf "\n"
	fi
	rm "${temp_file}"
}

print_arg_array() {
	local size=${#ARG_ARRAY[@]}
	for ((i=0; i<$size; i++)); do
		printf "\"%s\" " "${ARG_ARRAY[i]}"
	done
}

print_err_log () {
	printf "$RED$BOLD\nERRORS:$RESET\n"
	cat last_err_log.txt
}

tester_setup() {
	rm pipex
	# compiling
	make -C ${PIPEX_DIR} all
	printf "\n"
	cp ${PIPEX_DIR}pipex ./ 2> /dev/null
	if [ -f "${PIPEX_DIR}pipex" ] && [ -x "${PIPEX_DIR}pipex" ];then
		printf "%-20s$GREEN%-8s$RESET\n" "compiling" "[OK]"
	else
		printf "%-20s$RED%-8s  \"pipex\" not found. Control that correct path is set in tester file$RESET\n\n" "compiling" "[KO]"; exit 1
	fi

	# norminette
	if type "norminette" > /dev/null 2>&1; then
		if norminette ${PIPEX_DIR} | grep "Error!" | wc -l > /dev/null; then
			printf "%-20s$RED%-8s$RESET\n" "norminette" "[KO]"
		else
			printf "%-20s$GREEN%-8s$RESET\n" "norminette" "[OK]"
		fi
	else
		printf "$RED$BOLD norminette not found $RESET"
	fi

	echo -n > last_err_log.txt
	printf "\n\n$BOLD$MAGENTA%-90s%-8s%-8s%-8s%-8s\n$RESET" "Testname" "Out" "Exit" "Time" "Leaks"

	exec 2> /dev/null
}

print_test_case() {
	printf "${RED}%s\n" "$DELIMITER" 
	printf "test %i:\n${RESET}" ${TEST_NUM}

	printf "${BOLD}./pipex "
	print_arg_array

	printf "\n%s\n\n${RESET}" "${ARG_STR}"
}

print_header() {
	printf "${YELLOW}\n%s\n${RESET}" "$1"
}
