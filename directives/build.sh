#!/bin/bash
BASE=`pwd`
INSTALL_ROOT="$HOME/Proftpd/"
WEB="$INSTALL_ROOT/www.pdd/"
FTP="$INSTALL_ROOT/ftp.pdd/"
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
## Build linked
##
cd $BASE/linked/
echo -n "linked "
jade -t sgml -E 1200 -d $DSL $BASE/all_directives.sgml
##
## Building single files
##
cd $BASE/other/
echo -n "html "
jade -t sgml -E 1200 -V nochunks -d $DSL $BASE/all_directives.sgml > $BASE/other/all_directives.html
echo -n "pdf "
htmldoc -t pdf all_directives.html > all_directives.pdf
echo -n "ps "
htmldoc -t ps all_directives.html > all_directives.ps
echo "done"
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
function install
{
	#
	# /linked/
	# /other/
	#	directive_list.html
	#	directive_list.pdf
	#	directive_list.ps
	#	directive_source.tgz
	#
	echo -n "Installing "
	# Build the tarballs first
	echo -n "cleaning "
	rm -rf $WEB/directives/
	rm -rf $FTP/directives/
	mkdir -p $WEB/directives/linked/
	mkdir -p $FTP/directives/linked/
	#
	# linked
	#
	echo -n "linked "
	cd $BASE/linked/
	echo -n "tgz "
	tar -czf $BASE/other/directive_html_linked.tgz *html
	#
	echo -n "cp "
	cp *html $WEB/directives/linked/
	cp *html $FTP/directives/linked/
	#
	# Source
	#
	cd $BASE
	tar -czf $BASE/other/directives_src.tgz *sgml sgml/*
	#
	# full
	#
	echo -n "full "
	cd $BASE/other/
	cp * $WEB/directives/
	cp * $FTP/directives/
	#echo -n "userguide "
	#cp $BASE/other/directive_list.sgml $BASE/../userguide/
	echo "done"
}
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
