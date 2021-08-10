#!/usr/bin/env bash

echo "***************************"
echo "* Enviornment Variables ***"
echo "***************************"
printenv | sort
echo "***************************"

pushd $PWD > /dev/null

echo "Setting directory to $DOCS_SRC_PATH"
cd $DOCS_SRC_PATH

echo "Creating directory $DOCS_PROCESSED_PATH"
mkdir -p $DOCS_PROCESSED_PATH

echo "Cleaning $DOCS_PROCESSED_PATH"
# rm $DOCS_PROCESSED/*

echo "Processing documents at $PWD into $DOCS_PROCESSED_PATH"
find *.md -maxdepth 1 -type f -exec markdown-pp {} -o $DOCS_PROCESSED_PATH/{} \;

popd > /dev/null
