#!/bin/bash
# This script allow to use setup a liberty ready for production liberty profile


WLPPATTERN="/wlp-embeddable/wlp-*.zip"
if ls $WLPPATTERN 1> /dev/null 2>&1;
then
    printf "Setup the liberty for production"
    mkdir -p /wlp-embeddable/work
    mkdir -p /wlp-embeddable/wlp
    cd /wlp-embeddable/work/
    unzip -q $WLPPATTERN
    cp -R /wlp-embeddable/work/wlp/bin /wlp-embeddable/wlp/
    cp -R /wlp-embeddable/work/wlp/lib /wlp-embeddable/wlp/
    cp -R /wlp-embeddable/work/wlp/dev /wlp-embeddable/wlp/
else
    mkdir /wlp-embeddable/wlp
fi
