#!/bin/bash


ROOT=`pwd`
OUTPUT=${ROOT}/output/
SRC="$ROOT/sgml/"
DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"

WWW=$HOME/Proftpd/www.proftpd.org/docs/

mkdir -p $OUTPUT/linked/
cd $OUTPUT/linked/
rm -fv *html
jade -t sgml -E 1200 -d $DSL $OUTPUT/configuration.sgml

rsync -av $OUTPUT/linked/ $WWW/directives/linked/
#
#
#

