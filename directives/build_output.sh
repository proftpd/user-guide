#!/bin/sh

set -e
ROOT="$(dirname "$0")"
DSL="/usr/share/sgml/docbook/stylesheet/dsssl/modular/html/docbook.dsl"

directives_for_context()
{
	local context=$1
	shift

	grep -A3 Context "$ROOT/sgml/"* | fgrep "$context" | \
		cut -d '-' -f 1 | sed 's,.*/,,'
}

build_by_context()
{
	local context directive

	directives_for_context 'server config' >"$ROOT/output/context-serverconfig"
	directives_for_context '&lt;Global&gt;' >"$ROOT/output/context-Global"
	directives_for_context '&lt;VirtualHost&gt;' >"$ROOT/output/context-VirtualHost"
	directives_for_context '&lt;Anonymous&gt;' >"$ROOT/output/context-Anonymous"
	directives_for_context '&lt;Limit&gt;' >"$ROOT/output/context-Limit"
	directives_for_context '.ftpaccess' >"$ROOT/output/context-ftpaccess"

	rm -f "$ROOT/output/by_context_source.sgml"
	for context in serverconfig Global VirtualHost Anonymous Limit ftpaccess; do
		cat "$ROOT/definitions/context/$context" \
			>>"$ROOT/output/by_context_source.sgml"

		for directive in $(cat "$ROOT/output/context-$context"); do
			echo "<link linkend=\"$directive\">$directive</link>" \
				>>"$ROOT/output/context-$context.sgml"
		done

		echo "</para>" >>"$ROOT/output/by_context_source.sgml"
		echo "</refsect1>" >>"$ROOT/output/by_context_source.sgml"
		echo "</refentry>" >>"$ROOT/output/by_context_source.sgml"
		echo "" >>"$ROOT/output/by_context_source.sgml"
		echo "" >>"$ROOT/output/by_context_source.sgml"
	done
}

module_and_directive_list()
{
	local file module directive

	for file in $(find "$ROOT/sgml/" -type f); do
		module=$(grep -A 2 "<keyword>" "$file" |
			sed -n '/mod_/s/.*\(mod_[a-z]*\).*/\1/p')
		directive=${file##*/}
		echo "$module:$directive"
	done
}

build_by_module()
{
	local module_and_directive module directive
	local last_module

	rm -f "$ROOT/output/by_module_source.sgml"
	# Module name must always be first so the list is sorted
	# by module in our output.
	for module_and_directive in $(module_and_directive_list | sort -f); do
		module=${module_and_directive%%:*}
		directive=${module_and_directive##*:}

		if [ "$module" != "$last_module" ]; then
			if [ ! -e "$ROOT/definitions/module/$module" ]; then
				echo "$module doesn't have a module definition in $ROOT/definitions/module, skipping..." 1>&2
				continue
			fi

			cat "$ROOT/definitions/module/$module" \
				>>"$ROOT/output/by_module_source.sgml"
			last_module="$module"
		fi

		echo "<link linkend=\"$directive\">$directive</link>" \
			>>"$ROOT/output/by_module_source.sgml"

		echo "</para>" >>"$ROOT/output/by_module_source.sgml"
		echo "</refsect1>" >>"$ROOT/output/by_module_source.sgml"
		echo "</refentry>" >>"$ROOT/output/by_module_source.sgml"
		echo "" >>"$ROOT/output/by_module_source.sgml"
		echo "" >>"$ROOT/output/by_module_source.sgml"
	done
}

build_by_name()
{
	local file directive

	cat "$ROOT/sgml/"* >>"$ROOT/output/by_name_source.sgml"

	rm -f "$ROOT/output/directive_list.sgml"
	for file in "$ROOT/sgml/"*; do
		directive=${file##*/}
	
		echo "<link linkend=\"$directive\">$directive</link>" \
			>>"$ROOT/output/directive_list.sgml"
	done
}

rm -r "$ROOT/output"
mkdir -p "$ROOT/output/linked/"

build_by_context
build_by_module
build_by_name

# Both jade(1) invocations exit with status 1, probably because of our
# crappy SGML input. I hate blindly ignoring their exit status, but it's
# easier than fixing the SGML. :-/
jade -t sgml -V nochunks -E 100000 -d "$DSL" \
	"$ROOT/configuration.sgml" \
	>"$ROOT/output/configuration_full.html" || true

cd "$ROOT/output/linked/"
jade -t sgml -E 10000 -d "$DSL" "../../configuration.sgml" || true
