#!/bin/bash
#
# This script builds the list of modules into 
# a single file
#
ROOT=`pwd`
BASE="$ROOT/by_context/"
OUTPUT=${ROOT}/output/
SRC="$ROOT/sgml/"
#DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"
##
##
##
mkdir -p $BASE
cd $BASE
rm -fv *
cd $SRC
grep -A3 Context * | grep -q 'server config' | cut -d '-' -f 1 > $BASE/serverconfig
grep -A3 Context * | grep -q '&lt;Global&gt;' | cut -d '-' -f 1 > $BASE/Global
grep -A3 Context * | grep -q '&lt;VirtualHost&gt;' | cut -d '-' -f 1 > $BASE/VirtualHost
grep -A3 Context * | grep '&lt;Anonymous&gt;' | cut -d '-' -f 1 > $BASE/Anonymous
grep -A3 Context * | grep '&lt;Limit&gt;' | cut -d '-' -f 1 > $BASE/Limit
grep -A3 Context * | grep '.ftpaccess' | cut -d '-' -f 1 > $BASE/ftpaccess

#
# Start building pages...
#
echo "Working on "
mkdir -p $BASE/working
for context in serverconfig Global VirtualHost Anonymous Limit ftpaccess
do
	target="$BASE/working/${context}.sgml"
	if [ -f ${BASE}/definitions/${context} ]
	then
		cp ${BASE}/definitions/${context} ${target}
	else
		echo ""
		echo "Can't find ${BASE}/definitions/${context}"
		echo "touching ${target}"
		touch ${target}
	fi
	echo "${target} "
	for i in `cat $BASE/${context}`
	do
		echo "<link linkend=\"${i}\">${i}</link> " \
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
echo "Building by_context_source.sgml"
rm -f $OUTPUT/by_context_source.sgml
cd $BASE/working/
for context in serverconfig Global VirtualHost Anonymous Limit ftpaccess
do
	cat ${context}.sgml >> ${OUTPUT}/by_context_source.sgml
done
#
#
#
