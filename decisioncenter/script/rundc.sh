#!/bin/bash

"$SCRIPT"/addDCApplications.sh

"$SCRIPT"/updateDCConfigurations.sh

"$SCRIPT"/updatePersistenceLocale.sh

"$SCRIPT"/configureTlsSecurity.sh

"$SCRIPT"/configureDatabase.sh

"$SCRIPT"/updateDatasource.sh

"$SCRIPT"/configureSwidTag.sh

"$SCRIPT"/jvmOptions.sh

"$SCRIPT"/setTimeZone.sh

# shellcheck source=decisioncenter/script/setUTF8Locale.sh
# shellcheck disable=SC1091
. "$SCRIPT"/setUTF8Locale.sh

/opt/ibm/wlp/bin/server run defaultServer
