#!/bin/bash
#
# Script to manage the building of the userguide
#
BASE="$HOME/Proftpd/Userguide/"
INSTALL_ROOT="$HOME/Proftpd/"
WEB="$INSTALL_ROOT/www.pdd/"
FTP="$INSTALL_ROOT/ftp.pdd/"
DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"
#
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
	if [ ! -f directives/other/directive_list.sgml ]
	then
		echo "The directive list is missing, aborting"
		exit
	fi
	#
	# Building linked html
	# 
	echo -n "linked "
	cd $BASE/linked/
	jade -t sgml -E 1200 -d $DSL $BASE/main.sgml
	exit
	#
	# Building single html 
	#
	echo -n "html "
	cd $BASE/other/
	jade -t sgml -E 1200 -V nochunks -d $DSL \
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
	# Build the tarballs first
	echo "Cleaning"
	rm -rf $WEB/userguide/
	rm -rf $FTP/userguide/
	# source files
	echo "Tarballs"
	cd $BASE
	tar -czf userguide_source.tgz *sgml
	# linked
	echo "Copying linked files"
	cd $BASE/linked/
	tar -czf userguide_html_linked.tgz *html
	#
	mkdir -p $WEB/userguide/linked/
	mkdir -p $FTP/userguide/linked/
	cp *html $WEB/userguide/linked/
	cp *html $FTP/userguide/linked/
	cp userguide_html_linked.tgz $WEB/userguide/
	cp userguide_html_linked.tgz $FTP/userguide/
	# full
	echo "Copying single files"
	cd $BASE/other/
	cp userguide_full.html $WEB/userguide/
	cp userguide.pdf $WEB/userguide/
	cp userguide.ps $WEB/userguide/
	cp userguide_full.html $FTP/userguide/
	cp userguide.pdf $FTP/userguide/
	cp userguide.ps $FTP/userguide/
	#
	# copy the source
	#
	echo "Copying source files"
	cd $BASE
	mkdir $WEB/userguide/src/
	mkdir $FTP/userguide/src/
	cp *sgml $WEB/userguide/src/
	cp *sgml $FTP/userguide/src/
	##
	## install in www.proftpd.org root
	##
	## Make sure the directory exists
	#mkdir -p $INSTALL_ROOT/www.proftpd.org/docs/userguide/linked
	## copy linked version
	#cd $BASE/linked
	#cp *html $INSTALL_ROOT/www.proftpd.org/docs/userguide/linked
	#cd $BASE/other/
	#cp userguide_full.html userguide.pdf userguide.ps $INSTALL_ROOT/www.proftpd.org/docs/userguide


	## Rsyncing a copy to korenwolf
	rsync -av $HOME/Proftpd/www.pdd/userguide/  $HOME/websites/www.korenwolf.net/proftpd/Userguide/
	
	}

function installbeta {
	cd $HOME/Proftpd/Userguide/
	rsync --delete -av linked/ ~/websites/korenwolf/proftpd/beta/linked
	rsync --delete -av other/ ~/websites/korenwolf/proftpd/beta/other
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
