#!/bin/bash
#
# This script builds the list of modules into 
# a single file
#
ROOT=`pwd`
BASE="$ROOT/by_module/"
OUTPUT=${ROOT}/output/
SRC="$ROOT/sgml/"
#DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"
#

echo "Cleaning up before starting"
rm -fv $BASE/*.lst
rm -fvr $BASE/working

echo -n "Working..."
cd $BASE
mkdir -p linked
mkdir -p other
mkdir -p working
##
##
##
for i in `/bin/ls $SRC/* | sort -f`
do
	echo -n "."
	if [ -f ${i} ]
	then
###
#
# watch out! the regex requires `mod_' to be the first characters on a 
# line.  this means that when parsing the directive source files to 
# determine the module to which a directive refers, the module name
# as entered in the source file MUST be at the very beginning of a line.
# This places a formatting restriction on the sgml source files that 
# must be remembered by authors.
#
###
		module=`grep -s -A 3 "Module" ${i} | grep "^mod_"`
		file=`echo ${i} | sed "s/\/.*\///"` 
		echo "${file}:$module" >> module_by_directive.lst
	fi
done
echo "..done"

#
# List of modules
#
cut -d : -f 2 module_by_directive.lst | sort | uniq > module.lst

#
# Start building pages...
#
echo "Working on "
mkdir -p $BASE/working
for mod in `cat module.lst`
do
	target="$BASE/working/${mod}.sgml"
	if [ -f ${BASE}/definitions/${mod} ]
	then
		cp ${BASE}/definitions/${mod} ${target}
	else
		echo ""
		echo "Can't find ${BASE}/definitions/${mod}"
		echo "touching ${target}"
		touch ${target}
	fi
	echo "${target} "
	for i in `cat module_by_directive.lst | grep ":${mod}$"`
	do
		directive=`echo ${i} | sed "s/:.*//"`
		echo "<link linkend=\"${directive}\">${directive}</link> " \
			>> ${target}
	done
	echo "</para>" >> ${target}
	echo "</refsect1>" >> ${target}
	echo "</refentry>" >> ${target}
	echo "" >> ${target}
	echo "" >> ${target}
done
echo ""
#
# Right built all the sgml... 
#
echo "Building by_module_source.sgml"
rm -f $OUTPUT/by_module_source.sgml
cd $BASE/working/
for mod in `cat ${BASE}/module.lst`
do
	cat ${mod}.sgml >> ${OUTPUT}/by_module_source.sgml
done
#
#
#
