#!/bin/bash

if [ "$LICENSE" = "accept" ]; then
  exit 0
elif [ "$LICENSE" = "view" ]; then
  licenseFileBaseName="licenses/Lic"
  licenseFile=""

  case "$LANG" in
    zh_TW*) licenseFile="${licenseFileBaseName}_zh_TW.txt" ;;
    zh*) licenseFile="${licenseFileBaseName}_zh.txt" ;;
    cs*) licenseFile="${licenseFileBaseName}_cs.txt" ;;
    en*) licenseFile="${licenseFileBaseName}_en.txt" ;;
    fr*) licenseFile="${licenseFileBaseName}_fr.txt" ;;
    de*) licenseFile="${licenseFileBaseName}_de.txt" ;;
    el*) licenseFile="${licenseFileBaseName}_el.txt" ;;
    in*) licenseFile="${licenseFileBaseName}_in.txt" ;;
    it*) licenseFile="${licenseFileBaseName}_it.txt" ;;
    ja*) licenseFile="${licenseFileBaseName}_ja.txt" ;;
    ko*) licenseFile="${licenseFileBaseName}_ko.txt" ;;
    lt*) licenseFile="${licenseFileBaseName}_lt.txt" ;;
    pl*) licenseFile="${licenseFileBaseName}_pl.txt" ;;
    pt*) licenseFile="${licenseFileBaseName}_pt.txt" ;;
    ru*) licenseFile="${licenseFileBaseName}_ru.txt" ;;
    sl*) licenseFile="${licenseFileBaseName}_sl.txt" ;;
    es*) licenseFile="${licenseFileBaseName}_es.txt" ;;
    tr*) licenseFile="${licenseFileBaseName}_tr.txt" ;;
    *) licenseFile="${licenseFileBaseName}_en.txt" ;;
  esac

  cat $APPS/$licenseFile

  echo -e "Set environment variable LICENSE=accept to indicate acceptance of license terms and conditions."
  exit 1
else
  echo -e "Set environment variable LICENSE=accept to indicate acceptance of license terms and conditions.\n\nLicense agreements and information can be viewed by running this image with the environment variable LICENSE=view. You can also set the LANG environment variable to view the license in a different language."
  exit 1
fi
