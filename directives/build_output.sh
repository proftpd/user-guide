#!/bin/bash

ROOT=`pwd`
OUTPUT=${ROOT}/output/
SRC="$ROOT/sgml/"
if [ "$DSSSL_STYLESHEET_PATH" != "" ] 
then
  DSL="$DSSSL_STYLESHEET_PATH/html/docbook.dsl"
else 
  DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"
fi
WWW=$HOME/Proftpd/www.proftpd.org/docs/
FTP=$HOME/Proftpd/ftp.proftpd.org/docs/

$ROOT/build_by_name.sh
$ROOT/build_by_module.sh
$ROOT/build_by_context.sh

mkdir -p $OUTPUT/linked/
cd $OUTPUT/linked/
rm -fv *html
jade -t sgml -E 10000 -d $DSL $OUTPUT/configuration.sgml

cd $OUTPUT
jade -t sgml -V nochunks -E 100000 -d $DSL configuration.sgml > configuration_full.html

htmldoc -t pdf configuration_full.html > configuration.pdf
htmldoc -t ps configuration_full.html > configuration.ps

rsync -av --delete $OUTPUT/ $WWW/directives/
rsync -av --delete $OUTPUT/ $FTP/directives/
