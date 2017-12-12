#!/bin/bash

paramName=$1
oldValue=$2
newValue=$3
file=$4

echo "change the value of param $paramName from $oldValue to $newValue in $file"

# . matches any value
if [ $oldValue = "." ]
then
  oldValue=".*?"
fi

perl -i -p0e "s/(<param-name>$paramName<\/param-name>\s*<param-value>)($oldValue)(<\/param-value>)/\1$newValue\3/s" $file
