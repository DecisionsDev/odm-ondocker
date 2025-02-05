#!/bin/bash

if [ -n "$DOWNLOAD_URL" ]; then

        echo "Use DOWNLOAD_URL: $DOWNLOAD_URL"

        if [ ! -d /config/download ]; then
                mkdir /config/download
        fi

        cd /config/download

        # Download files from each urls
        IFS=','
        read -a download_urls <<< "$DOWNLOAD_URL"
        for url in "${download_urls[@]}"; do
                curl -O -k -s -L $url
        done

        shopt -s nullglob

        # Unzip download if necessary
        for arch in *.zip; do
                unzip -q ${arch}
                rm ${arch}
        done

        # Untar download if necessary (.tgz, .tar, .tar.gz, .tar.bz2, .tar.xz are supported)
        for arch in *.tar* *.tgz; do
                tar -xaf ${arch}
                rm ${arch}
        done

fi
