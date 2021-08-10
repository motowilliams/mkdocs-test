#!/usr/bin/env bash

printenv | sort

pushd $PWD > /dev/null

cd $DOCS_SRC
mkdir -p $DOCS_PROCESSED
find *.md -maxdepth 1 -type f -exec markdown-pp {} -o $DOCS_PROCESSED/{} \;

popd > /dev/null
