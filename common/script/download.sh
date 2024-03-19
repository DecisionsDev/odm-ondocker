#!/bin/bash

if [ -n "$DOWNLOAD_URL" ]
then
        echo "Use DOWNLOAD_URL: $DOWNLOAD_URL"

	if [ ! -d /config/download ]; then
           mkdir /config/download
        fi

        # Download files from each urls
        IFS=','
        read -a download_urls <<< "$DOWNLOAD_URL"
        for url in "${download_urls[@]}";
        do
          (cd /config/download && curl -O -k -s -L $url)
        done

        # Unzip download if necessary
        if [ -f /config/download/*.zip ]; then
                (cd /config/download && unzip -q *.zip)
        fi

        # Untar download if necessary (.tar, .tar.gz, .tar.bz2, .tar.xz are supported)
        if [ -f /config/download/*.tar* ]; then
                for arch in "/config/download"/*.tar*
                do
                  (cd /config/download && tar -xaf $arch)
                done
        fi
        if [ -f /config/download/*.tgz* ]; then
                for arch in "/config/download"/*.tgz*
                do
                  (cd /config/download && tar -xaf $arch)
                done
        fi
fi
