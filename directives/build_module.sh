#!/bin/bash
#
# Build the pages for the directive by module listing
#
ROOT=`pwd`
SRC="$ROOT/sgml/"
#
rm *.lst
rm -f by_module/*
#
echo -n "Working..."
for i in `/bin/ls $SRC/* | sort -f`
do
	echo -n "."
	if [ -f ${i} ]
	then
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
echo -n "Working on "
mkdir by_module
for mod in `cat module.lst`
do
	target="by_module/${mod}.sgml"
	if [ -f modules/${mod} ]
	then
		cp modules/${mod} ${target}
	else
		touch ${target}
	fi
	echo -n "${target} "
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
rm -f $ROOT/by_module_source.sgml
cd $ROOT/by_module/
for mod in `cat ${ROOT}/module.lst`
do
	cat ${mod}.sgml >> ${ROOT}/by_module_source.sgml
done
cp ${ROOT}/by_module_source.sgml $HOME/Proftpd/www.pdd/userguide/
#
#
#
