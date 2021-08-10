#!/usr/bin/env bash

echo "***************************"
echo "* Enviornment Variables ***"
echo "***************************"
printenv | sort
echo "***************************"

echo -n "Saving current directory location of $PWD"
pushd $PWD > /dev/null

echo
echo "Setting directory to $DOCS_SRC_PATH"
cd $DOCS_SRC_PATH

echo "Ensuring and cleaning directory $DOCS_PROCESSED_PATH"
mkdir -p $DOCS_PROCESSED_PATH
rm $DOCS_PROCESSED_PATH/*

echo "Saving enviornment variables as files for preprocessor"
mkdir -p ../env/
while IFS='=' read -r -d '' n v; do echo -n "$v" > ../env/"$n"; done < <(env -0)

echo "Processing documents at $PWD into $DOCS_PROCESSED_PATH"
find *.md -maxdepth 1 -type f -exec markdown-pp {} -o $DOCS_PROCESSED_PATH/{} \;

echo -n "Setting directory to "
popd
