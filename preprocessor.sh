#!/usr/bin/env bash

echo "*************************"
echo "* Enviornment Variables *"
echo "*************************"
printenv | sort
echo "*************************"

echo
WORK_DIR=$(find . -name "mkdocs.yml" | sed "s/mkdocs.yml//")
echo "Setting directory to $WORK_DIR"
cd $WORK_DIR

echo "Saving enviornment variables as files for preprocessor"
rm -rf $DOCS_ENV_PATH
mkdir -p $DOCS_ENV_PATH
while IFS='=' read -r -d '' n v; do echo -n "$v" > $DOCS_ENV_PATH/"$n"; done < <(env -0)

echo "Processing documents at $DOCS_SRC_PATH into $DOCS_PROCESSED_PATH"
rsync --recursive --delete $DOCS_SRC_PATH/ $DOCS_PROCESSED_PATH/
cd $DOCS_SRC_PATH
find . -name "*.md" -type f -exec echo "Processing" {} \; -exec markdown-pp {} -o $DOCS_PROCESSED_PATH/{} \;

echo -n "Setting directory to "
cd $WORK_DIR
