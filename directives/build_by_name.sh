#!/bin/bash
#
# This script builds the list of directives into 
# a single file
#
ROOT=`pwd`
BASE=${ROOT}/by-name/
OUTPUT=${ROOT}/output/
SRC=${ROOT}/sgml/
if [ "$DSSSL_STYLESHEET_PATH" != "" ]
then
  DSL="$DSSSL_STYLESHEET_PATH/html/docbook.dsl"
else
  DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"
fi

function build
{
rm -fv ${OUTPUT}/by_name_source.sgml
rm -fv $ROOT/other/directive_list.sgml

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
#jade -t sgml -d $DSL $BASE/index.sgml
}

build
#
# end
#
