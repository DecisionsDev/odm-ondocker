#!/bin/bash

# parameters:
# $1 the param-name
# $2 old value
# $3 new value
# $4 the web.xml file path

echo "change the value of param $1 from $2 to $3 in $4"

perl -i -p0e "s/(<param-name>$1<\/param-name>\s*<param-value>)($2)(<\/param-value>)/\1$3\3/s" $4
