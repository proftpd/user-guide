#!/bin/bash
#
# This script builds the list of directives into 
# a single file
#
ROOT=`pwd`
BASE=${ROOT}/by-name/
OUTPUT=${ROOT}/output/
SRC=${ROOT}/sgml/
#DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"

function build
{
rm -fv ${OUTPUT}/by_name_source.sgml
echo -n "Building "
#
# Building directive file
#
echo -n "sgmlcat "
cd $SRC
for i in *
do
	if [ -f ${i} ]
	then
		cat ${i} >> $OUTPUT/by_name_source.sgml
	fi
done
#jade -t sgml -E 1200 -d $DSL $BASE/by_name/index.sgml
}

build
#
# end
#
