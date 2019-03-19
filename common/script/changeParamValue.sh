#!/bin/bash

paramName=$1
oldValue=$2
newValue=$3
file=$4

echo "Change the value of parameter $paramName from $oldValue to $newValue in $file"

# . matches any value
if [ $oldValue = "." ]
then
  oldValue=".*?"
fi

sed -i '/<param-name>'$paramName'<\/param-name>/{n;s/'$oldValue'/'$newValue'/;}' $file
