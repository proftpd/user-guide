#!/bin/bash
#
# Script to manage the building of the userguide
#
BASE="`pwd`"
INSTALL_ROOT="$HOME/Proftpd/"
##
## Test to see if we can find a stylesheet using a 
## provided path
##
if [ -f $DSSSL_STYLESHEET_PATH/html/docbook.dsl ]
then
  DSL="$DSSSL_STYLESHEET_PATH/html/docbook.dsl"
else
  # Fall back to a hardcoded default
  DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"
fi

function clean
{
#
# Clean up
#
cd $BASE
rm -rf linked
rm -rf other
mkdir -p ./linked/
mkdir -p ./other/
}
#
function build
{
	clean
	echo -n "Building "
#	if [ ! -f directives/other/directive_list.sgml ]
#	then
#		echo "The directive list is missing, aborting"
#		exit
#	fi
	#
	# Building linked html
	# 
	echo -n "linked "
	cd $BASE/linked/
	jade -t sgml -E 20 -d $DSL $BASE/main.sgml
	#
	# Building single html 
	#
	echo -n "html "
	cd $BASE/other/
	jade -t sgml -V nochunks -d $DSL \
		$BASE/main.sgml > userguide_full.html 
	#	
	# Building PS & PDF
	#
	echo -n "pdf "
	htmldoc -t pdf userguide_full.html > userguide.pdf
	echo -n "ps "
	htmldoc -t ps userguide_full.html > userguide.ps
	echo "."
}

function install
{
	cd $BASE/linked
	rsync -av * ~/Proftpd/www.proftpd.org-new/localsite//Userguide/linked
	cd $BASE/other
	rsync -av * ~/Proftpd/www.proftpd.org-new/localsite//Userguide/other  
}

function installbeta {
	cd $HOME/Proftpd/Userguide/
	rsync --delete -av linked/ ~/Proftpd/www.proftpd.org/localsite/beta/linked
	rsync --delete -av other/ ~/Proftpd/www.proftpd.org/localsite/beta/other
} 
#
#
#
case "$1" in
	build)
  		echo "Building userguide"
  		build
		;;
	install)
		echo "Installing pages"
		install
		;;
	beta)
		build
		installbeta
		;;
	installbeta)
		installbeta
		;;
	clean)
		echo "Nuking built"
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
