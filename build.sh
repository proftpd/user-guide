#!/bin/sh

BASE="$(pwd)"
DSL="/usr/share/sgml/docbook/stylesheet/dsssl/modular/html/docbook.dsl"

jade -t sgml -V nochunks -d "$DSL" "$BASE/main.sgml" \
	>"$BASE/userguide_full.html"

cd "$BASE/linked/"
jade -t sgml -E 20 -d "$DSL" "$BASE/linked/../main.sgml"

