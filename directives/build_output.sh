#!/bin/bash

ROOT=`pwd`
OUTPUT=${ROOT}/output/
SRC="$ROOT/sgml/"
DSL="/usr/lib/sgml/stylesheet/dsssl/docbook/nwalsh/html/docbook.dsl"
WWW=$HOME/Proftpd/www.proftpd.org/docs/

$ROOT/build_by_name.sh
$ROOT/build_by_module.sh
$ROOT/build_by_context.sh

mkdir -p $OUTPUT/linked/
cd $OUTPUT/linked/
rm -fv *html
jade -t sgml -E 1200 -d $DSL $OUTPUT/configuration.sgml

cd $OUTPUT
jade -t sgml -E 1200 -V nochunks -d $DSL configuration.sgml > configuration_full.html

htmldoc -t pdf configuration_full.html > configuration.pdf
htmldoc -t ps configuration_full.html > configuration.ps

rsync -av --delete $OUTPUT/ $WWW/directives/
#
#
#

