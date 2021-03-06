#!/bin/bash

# This file serves as a template for run scripts for new benchmarks.
# Most parts of the script may be left unchanged. The parts which depend
# on the current benchmark are marked.
#
# If your PATH variable contains the path to the "scripts" directory of
# the ABC benchmarking system, then the benchmarks can be started by calling
#	./run.sh
# Otherwise, you may explicitly specify the path by calling
#	./run.sh all 300 PATH_TO_ABCBENCHMARKING_SCRIPTS
#
# In many cases, run scripts will be exactly like this template until the
# very last if block (*). Thus they may simply include this part,
# provided in file run_header.sh and continue with
# an adopted version of block (*), as follows:	
#
# 	runheader=$(which run_header.sh)
# 	if [[ $runheader == "" ]] || [ $(cat $runheader | grep "run_header.sh Version 1." | wc -l) == 0 ]; then
# 		echo "Could not find run_header.sh (version 1.x); make sure that the benchmarks/script directory is in your PATH"
# 		exit 1
# 	fi
# 	source $runheader
#
#	[adopted block (*)]
#
# Note: The scripts output some additional information to stderr,
#       which should be redirected to /dev/null unless you are debugging.

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
	if [[ $# -ge 3 ]]; then
		bmscripts=$3
	fi
else
	instance=$2
	to=$3
	if [[ $# -ge 4 ]]; then
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
		$bmscripts/runinsts.sh "$loop" "$mydir/run.sh" "$mydir" "$to" "$customaggregationscript" "$bmname"
	else
		# run single instance
		$bmscripts/runconfigs.sh "$static" "$confstr" "$instance" "$to" "$customoutputbuilder"
	fi

}

#
# (*)
# 
# HERE THE BENCHMARK-SPECIFIC PART STARTS
# 
# Mandatory:
# - Replace "instances/*.hex" in (1) by the loop condition to be used for iterating over the instances
# - Define the variable "confstr" in (2) as a semicolon-separated list of configurations to compare.
# - In (3) replace "dlvhex2 --plugindir=../../src INST CONF" by an appropriate call of the reasoner, where INST will be substituted by the instance file and CONF by the current configuration from variable "confstr".
# 
# Optional:
# - Specify a custom benchmark name (4)
# - Specify a custom aggregation script (5)
# - Specify a custom output builder (6)

loop="instances/\*.hex"                                        # (1)
confstr="--solver=genuinegc;--solver=genuineii"                # (2)
static="dlvhex2 --plugindir=../../src INST CONF"               # (3)
bmname=""                                                      # (4)
customaggregationscript=""                                     # (5)
customoutputbuilder=""                                         # (6)

run "$loop" "$confstr" "$static" "$bmname" "$customaggregationscript" "$customoutputbuilder"
