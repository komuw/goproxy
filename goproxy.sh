#!/usr/bin/env bash

# https://github.com/anordal/shellharden/blob/master/how_to_do_things_safely_in_bash.md

if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi

# usage:
printf """\n
example usage:
  ./goproxy.sh -l /tmp/myGoProxy -m github.com/pkg/errors -v v0.8.0
"""

while getopts ":l:m:v:" opt; do
  case $opt in
    l) GOPROXY_LOCATION="$OPTARG"
    ;;
    m) MODULE_NAME="$OPTARG"
    ;;
    v) MODULE_VERSION="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done
ZIPPING_LOCATION=/tmp/zipper

if [ "$GOPROXY_LOCATION" == ""  ]; then
    printf """\n
    location should not be empty
    \n"""
    exit
fi
if [ "$MODULE_NAME" == ""  ]; then
    printf """\n
    module name should not be empty
    \n"""
    exit
fi
if [ "$MODULE_VERSION" == ""  ]; then
    printf """\n
    module version should not be empty
    \n"""
    exit
fi

printf """\n
You have chosen:
GOPROXY location: $GOPROXY_LOCATION
Module: $MODULE_NAME
Version: $MODULE_VERSION
\n"""


# 1.
printf """\n
1. downloading: module=$MODULE_NAME version=$MODULE_VERSION
\n"""
mkdir -p $ZIPPING_LOCATION
wget -nc --directory-prefix=$ZIPPING_LOCATION https://$MODULE_NAME/archive/$MODULE_VERSION.zip
unzip $ZIPPING_LOCATION/$MODULE_VERSION.zip -d $ZIPPING_LOCATION
mkdir -p $ZIPPING_LOCATION/$MODULE_VERSION
mv $ZIPPING_LOCATION/*/* $ZIPPING_LOCATION/$MODULE_VERSION
mkdir -p $ZIPPING_LOCATION/$MODULE_NAME@$MODULE_VERSION
cp -r $ZIPPING_LOCATION/$MODULE_VERSION/* $ZIPPING_LOCATION/$MODULE_NAME@$MODULE_VERSION
zip /tmp/$MODULE_VERSION.zip $ZIPPING_LOCATION/$MODULE_NAME@$MODULE_VERSION/*

# 2.
printf """\n
2. adding: module=$MODULE_NAME version=$MODULE_VERSION to $GOPROXY_LOCATION
\n"""
mkdir -p $GOPROXY_LOCATION
mkdir -p $GOPROXY_LOCATION/$MODULE_NAME/@v
echo "${MODULE_VERSION}" >> $GOPROXY_LOCATION/$MODULE_NAME/@v/list
echo "{"\"Version"\":"\"$MODULE_VERSION"\", "\"Time"\":"\"2016-09-29T01:48:01Z"\"}" >> $GOPROXY_LOCATION/$MODULE_NAME/@v/$MODULE_VERSION.info
echo "module $MODULE_NAME" >> $GOPROXY_LOCATION/$MODULE_NAME/@v/$MODULE_VERSION.mod
cp /tmp/$MODULE_VERSION.zip $GOPROXY_LOCATION/$MODULE_NAME/@v/

# 3. clean up
printf """\n
3. cleaning up...
\n"""
rm -rf $ZIPPING_LOCATION

# 4. set proxy env
printf """\n
4. success:
to use this proxy, set GOPROXY=file:///$GOPROXY_LOCATION
eg: export GOPROXY=file:///$GOPROXY_LOCATION
\n"""