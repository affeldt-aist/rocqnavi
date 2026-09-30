#!/bin/bash
set -eu

DIR=$(cd $(dirname $0) && pwd)

RocqNavi=$DIR/../../rocqnavi

rm -rf $DIR/html
mkdir $DIR/html

cd $DIR
VFiles="Main.v"
rocq compile $VFiles

GlobFiles="Main.glob"
$RocqNavi -title "test_type_tooltip" -d ./html $VFiles $GlobFiles \
    -file-references-on-right-pane \
    -show-type-information-using-rocq-lsp

# Check html files
# xq decodes "&nbsp;" entities into the raw NBSP byte sequence (0xc2 0xa0).
# Whether `diff -w` treats that byte sequence as equivalent to a plain space
# depends on the process locale (LC_CTYPE), so normalize NBSP to a plain
# space ourselves instead of relying on locale-dependent whitespace folding.
norm_nbsp() { LC_ALL=C sed $'s/\xc2\xa0/ /g'; }
if command -v xq >/dev/null 2>&1; then
    for exp_html in $DIR/expected_html/*.html
    do
        base=$(basename $exp_html)
        act_html=$DIR/html/$base
        echo "checking $base..."
        if type xq > /dev/null 2>&1; then
            diff -uw <(xq $exp_html | norm_nbsp) <(xq $act_html | norm_nbsp)
        else
            diff -uw $exp_html $act_html
        fi
    done
else
    # Check other resource files and directories
    diff -ruwB -x rocqnavi.css -x rocqnavi.js \
         $DIR/expected_html $DIR/html
fi
