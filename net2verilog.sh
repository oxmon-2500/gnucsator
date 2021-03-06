#!/bin/bash
# this is gnucsator, gnucap in qucsator mode.
# it loads plugins and switches to qucs language.
#
# this sucks.
# to be replaced by a "qucsator" binary, once
# shared library and output pluggability are ready.
# the .sh extension is intentional.

#THIS_FILE_IS_AUTOMATICALLY_GENERATED

TEMP=`getopt -o i:o:bg --long input:output: \
     -n 'gnucsator.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

while true; do
	case "$1" in
		-b) shift;;
		-g) shift;;
		-i|--input) infile="$2"; shift 2;;
		-o|--output) outfile="$2"; shift 2;;
		--) shift; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

GNUCSATOR=gnucsator

save=list
if [ -n "$2" ]; then
	save="save $2"
fi

$GNUCSATOR <<EOF
qucs

include $1

.verilog
$save

EOF
