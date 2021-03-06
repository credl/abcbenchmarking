#!/bin/bash

# run_header.sh Version 1.0		Do not remove or change this line!
#						This allows run scripts to detect that this is the proper run header file
#						Only the minor version may be changed, a change in the major version
#						makes existing scripts fail.

# check input validity
inputok=1
if [[ $# -eq 0 ]]; then
	inputok=1
elif [[ $1 != "" ]] && [[ $1 != "all" ]] && [[ $1 != "allseq" ]] && [[ $1 != "single" ]]; then
	inputok=0
elif [[ $1 == "single" ]] && [[ $# -lt 3 ]]; then
        inputok=0
fi
if [[ $inputok -eq 0 ]]; then
	echo "This script expects 0 to 5 parameters" >&2
	echo "   \$1: (optional) \"all\", \"allseq\" or \"single\", default is \"all\"" >&2
	echo "   (a) If \$1=\"all\" then there are no further mandatory parameters" >&2
	echo "       \$2: (optional) timeout, default is 300" >&2
	echo "       \$3: (optional) directory with the benchmark scripts" >&2
        echo "       \$4: (optional) requirements file" >&2
	echo "   (b) If \$1=\"allseq\" then there are no further mandatory parameters" >&2
	echo "       \$2: (optional) timeout, default is 300" >&2
	echo "       \$3: (optional) directory with the benchmark scripts" >&2
	echo "       This will execute all instances sequentially (Condor HT is not used)" >&2
	echo "   (c) If \$1=\"single\" then" >&2
	echo "       \$2: instance name" >&2
	echo "       \$3: timeout in seconds" >&2
	echo "       \$4: (optional) directory with the benchmark scripts" >&2
	exit 1
fi

# set default values
# and get location of benchmark scripts
if [[ $# -eq 0 ]]; then
	all=1
elif [[ $1 == "" ]]; then
	all=1
elif [[ $1 == "all" ]]; then
	all=1
elif [[ $1 == "allseq" ]]; then
	all=1
	req="reqseq"
else
	all=0
fi
if [[ $all -eq 1 ]]; then
	if [[ $# -ge 2 ]] && [[ $2 != "" ]]; then
		to=$2
	else
		to=300
	fi
	if [[ $# -ge 3 ]] && [[ $3 != "" ]]; then
		bmscripts=$3
	fi
        if [[ $# -ge 4 ]]; then
                req=$4
        fi
else
	instance=$2
	to=$3
	if [[ $# -ge 4 ]] && [[ $4 != "" ]]; then
		bmscripts=$4
	fi
fi
if [[ $bmscripts == "" ]]; then
	runinstsdir=$(which runinsts.sh | head -n 1)
	if [ -e "$runinstsdir" ]; then
		bmscripts=$(dirname "$runinstsdir")
	fi
fi
if ! [ -e "$bmscripts" ]; then
	echo "Could not find benchmark scripts"
	exit 1
fi

# get directory where this script is executed from
mydir="$(dirname $0)"
mydir=$(cd $mydir; pwd)

function run {

	loop=$1
	confstr=$2
	static=$3
	bmname=$4
	customaggregationscript=$5
	customoutputbuilder=$6

	if [[ $all -eq 1 ]]; then
		# run all instances using the benchmark script runinsts.sh
		me=`basename "$0"`
		$bmscripts/runinsts.sh "$loop" "$mydir/$me" "$mydir" "$to" "$customaggregationscript" "$bmname" "$req"
	else
		# run single instance
		$bmscripts/runconfigs.sh "$static" "$confstr" "$instance" "$to" "$customoutputbuilder"
	fi

}

