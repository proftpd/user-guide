#!/bin/bash
BASE=`pwd`
DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"

function build
{
clean
echo -n "Building "
#
# Building directive file
#
echo -n "sgmlcat "
cd $BASE/sgml/
for i in *
do
	if [ -f ${i} ]
	then
		cat ${i} >> $BASE/other/directive_list.sgml
	fi
done
##
## Build linked version
##
mkdir -p $BASE/by_name/linked/
cd $BASE/by_name/linked/
echo -n "linked "
jade -t sgml -E 1200 -d $DSL $BASE/by_name/index.sgml
##
## Building single files
##
#cd $BASE/other/
#echo -n "html "
#jade -t sgml -E 1200 -V nochunks -d $DSL $BASE/all_directives.sgml > $BASE/other/all_directives.html
#echo -n "pdf "
#htmldoc -t pdf all_directives.html > all_directives.pdf
#echo -n "ps "
#htmldoc -t ps all_directives.html > all_directives.ps
#echo "done"
#
# end
#
}

function clean
{
#
# Clean up
#
echo -n "Cleaning "
cd $BASE
rm -rf linked
rm -rf other
mkdir -p ./linked/
mkdir -p ./other/
echo "done"
}
#
#
#
case "$1" in
	build)
  		build
		;;
	install)
		install
		;;
	clean)
		clean
		;;
	all)
		build
		install
		;;
	*)
		echo "Usage: build.sh (build|clean|install|all)"
    	exit 1
		;;
esac
#
