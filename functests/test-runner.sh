#!/bin/bash
if [ -z "${V}" ]; then
	V=0
fi

# checking prereqs
if [ -z "${OC}" ]; then
	OC=oc
fi
if [ -z "${KUBECTL}" ]; then
	KUBECTL="${OC}"
fi

export OC
export KUBECTL

MISSING=0
#for EXE in jq; do
#	if [ ! which -- ${EXE} &> /dev/null ]; then
#		echo "missing executable: ${EXE}"
#		MISSING=1
#	fi
#done
[ "${MISSING}" != "0" ] && exit 4

# we can run the real tests now
RET=0
for testscript in $( ls ??-test-*.sh); do
	testname=$(basename -- "$testscript")
	testname="${testname%.*}"  # see http://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

	result="???"
	if [ "${V}" == "0" ]; then
		./$testscript &> /dev/null
	else
		printf "* TESTCASE [%-64s] START\n" $testscript
		./$testscript
	fi
	if [ "$?" == "0" ]; then
		result="OK"
	else
		if [ "$?" == "99" ] ; then
			result="SKIP"
		else
			result="FAILED"
			RET=1
		fi
	fi
	if [ "${V}" == "0" ]; then
		printf "* [%-64s] %s\n" $testscript $result
	else
		printf "  TESTCASE [%-64s] %s\n" $testscript $result
	fi
done
exit $RET
