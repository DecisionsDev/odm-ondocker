#!/bin/bash

echo "Update web.xml file of Decision Server Runtime / RES Console"

function updateContextInitParamInWebXml() {
  action="$1"        # update | remove
  paramName="$2"     # <param-name>
  paramValue="$3"    # <param-value>, required for update
  scope="$4"         # context-param | init-param
  webXml="$APPS/$5"        # web.xml to be updated

  case "$action" in
    update)
      if [[ "$scope" == "context-param" ]]; then
        searchContextParam=$(xmllint --xpath "boolean(//*[local-name()='web-app']/*[local-name()='context-param']/*[local-name()='param-name' and text()='$paramName'])" "$webXml")
        if [[ $searchContextParam == "true" ]]; then
          currentContextParamValue=$(xmllint --xpath "string(//*[local-name()='context-param'][*[local-name()='param-name' and text()='$paramName']]/*[local-name()='param-value'])" "$webXml" 2>/dev/null)
          if [[ "$currentContextParamValue" == "$paramValue" ]]; then
            echo "$scope '$paramName' already has value '$paramValue'. No update needed."
          else          
            result="$(xmllint --shell "$webXml" 2>&1 >/dev/null << EOF 
setns x=https://jakarta.ee/xml/ns/jakartaee
cd x:web-app/x:context-param[x:param-name='$paramName']/x:param-value
set $paramValue
save
EOF
)"
          	if [[ "$result" != *"error"* ]]; then
		          echo "Updated $scope '$paramName' from '$currentContextParamValue' to '$paramValue' in the web.xml file"
	          else
		          echo "Unable to set property '$paramName' in the web.xml file"
	          fi
          fi
        else
          echo "Adding $scope '$paramName' with value '$paramValue'"
          sed -i '/<\/context-param>/!b;x;s/^/1/;/^1$/!{x;b};x;a\
\t<context-param>\
\t\t<param-name>'$paramName'</param-name>\
\t\t<param-value>'$paramValue'</param-value>\
\t</context-param>
' "$webXml"
        fi
      elif [[ "$scope" =~ ^filter:(.+)$ ]]; then
        filterName="${BASH_REMATCH[1]}"
        searchInitParam=$(xmllint --xpath "boolean(//*[local-name()='filter'][*[local-name()='filter-name' and text()='$filterName']]/*[local-name()='init-param']/*[local-name()='param-name' and text()='$paramName'])" "$webXml")
        if [[ $searchInitParam == "true" ]]; then        
          currentInitParamValue=$(xmllint --xpath "string(//*[local-name()='filter'][*[local-name()='filter-name' and text()='$filterName']]/*[local-name()='init-param'][*[local-name()='param-name' and text()='$paramName']]/*[local-name()='param-value'])" "$webXml" 2>/dev/null)
          if [[ "$currentInitParamValue" == "$paramValue" ]]; then
            echo "$scope '$paramName' already has value '$paramValue'. No update needed."
          else
            result="$(xmllint --shell "$webXml" 2>&1 >/dev/null<< EOF
setns x=https://jakarta.ee/xml/ns/jakartaee
cd x:web-app/x:filter[x:filter-name='$filterName']/x:init-param[x:param-name='$paramName']/x:param-value
set $paramValue
save
EOF
)"
          	if [[ "$result" != *"error"* ]]; then
		          echo "Updated $scope '$paramName' from '$currentInitParamValue' to '$paramValue' in the web.xml file"
	          else
		          echo "Unable to set property '$paramName' in the web.xml file"
	          fi
          fi
        else
          searchFilter=$(xmllint --xpath "boolean(//*[local-name()='filter'][*[local-name()='filter-name' and text()='$filterName']])" "$webXml")
          if [[ $searchFilter == "true" ]]; then
            echo "Adding $scope '$paramName' with value '$paramValue'"
            sed -i "/<filter>/,/<\/filter>/{/<filter-name>$filterName<\/filter-name>/,/<\/filter>/{/<filter-class>[^<]*<\/filter-class>/a\\
\\t\\t<init-param>\\
\\t\\t\\t<param-name>$paramName</param-name>\\
\\t\\t\\t<param-value>$paramValue</param-value>\\
\\t\\t</init-param>
  }
}" "$webXml"
          else
            echo "Filter $filterName not found. $paramName with value $paramValue will not be added"
          fi
        fi
      fi
      ;;

    remove)
      if [ "$scope" = "context-param" ]; then
        searchContextParam=$(xmllint --xpath "boolean(//*[local-name()='web-app']/*[local-name()='context-param']/*[local-name()='param-name' and text()='$paramName'])" "$webXml")
        if [[ $searchContextParam == "true" ]]; then
          echo "Removing $scope: $paramName"
          sed -i "/<context-param>/{:a;N;/<\/context-param>/!ba;/<param-name>$paramName<\/param-name>/d}" "$webXml"
        else
          echo "'$paramName' not found in $scope. No removal needed."
        fi
      elif [[ "$scope" =~ ^filter:(.+)$ ]]; then
        filterName="${BASH_REMATCH[1]}"
        searchInitParam=$(xmllint --xpath "boolean(//*[local-name()='filter'][*[local-name()='filter-name' and text()='$filterName']]/*[local-name()='init-param']/*[local-name()='param-name' and text()='$paramName'])" "$webXml")
        if [[ $searchInitParam == "true" ]]; then
          echo "Removing $scope: $paramName"
          # Removes the <init-param> block containing $paramName from the filter with name $filterName in the web.xml file
          sed -i "/<filter>/,/<\/filter>/{ /<filter-name>$filterName<\/filter-name>/,/<\/filter>/{ /<init-param>/{:a;N;/<\/init-param>/!ba;/<param-name>$paramName<\/param-name>/d} } }" "$webXml"
        else
          echo "'$paramName' not found in $scope. No removal needed."
        fi
      fi
      ;;
      
    *)
      echo "Invalid action: $action"
      echo "Usage: updateContextInitParamInWebXml <update|remove> <paramName> [paramValue] <context-param|init-param>"
      return 1
      ;;
  esac
}

function applyWebXmlChangesFromFile() {
  webXmlFile="$1"
  propertyFile="$2"
  scope=""  # valid section: context-param / filter:RequestFilter / filter:response-headers

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim whitespace
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

    # Skip empty or commented lines
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Detect section headers [context-param] / [filter:RequestFilter] / [filter:response-headers]
    if [[ "$line" =~ ^\[(.+)\]$ ]]; then
      section="${BASH_REMATCH[1]}"
      if [[ "$section" == "context-param" ]]; then
        scope="context-param"
      elif [[ "$section" =~ ^filter:(.+)$ ]]; then
        scope=$section
      else
        echo "Warning: Unknown section [$section]"
        scope="unknown"
      fi
      continue
    fi

    # Remove case: -paramName or -paramName=paramValue
    if [[ "$line" =~ ^-([[:alnum:]._-]+)([=].*)? ]]; then
      paramName="${BASH_REMATCH[1]}"
      [[ -z "$scope" ]] && scope="context-param"   # default if missing
      updateContextInitParamInWebXml remove "$paramName" "" "$scope" "$webXmlFile"

    # Add/Update case: paramName=paramValue
    elif [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
      [[ -z "$scope" ]] && scope="context-param"   # default if missing
      if [[ "$scope" == "context-param" || "$scope" == "filter:RequestFilter" || "$scope" == "filter:response-headers" ]]; then
        paramName="${BASH_REMATCH[1]}"
        paramValue="${BASH_REMATCH[2]}"

        if [[ -n "$paramValue" ]]; then
          # First, replace escaped # with a temporary placeholder
          paramValue="${paramValue//\\#/ESCAPED_HASH_PLACEHOLDER}"
            
          # Strip tailing comments
          paramValue="$(echo "$paramValue" | sed 's/[[:space:]]*#.*$//')"
            
          # Finally, restore escaped # characters
          paramValue="${paramValue//ESCAPED_HASH_PLACEHOLDER/#}"

          # Escape special characters & < > in parameter value
          paramValue="${paramValue//&/&amp;}"
          paramValue="${paramValue//</&lt;}"
          paramValue="${paramValue//>/&gt;}"
          updateContextInitParamInWebXml update "$paramName" "$paramValue" "$scope" "$webXmlFile"
        else
          echo "The param value of $paramName is null. No action taken. Check your configuration file."
        fi
      else
        echo "No action as the scope: $scope should be context-param, filter:response-headers, or filter:RequestFilter. Check your configuration file."
      fi
    else
      echo "Skipping invalid line: $line"
    fi
  done < "$propertyFile"
}

webXmlToConfigure="$1"
configFile="$2"
if [ -f "$configFile" ]; then
	echo "Configure context-param or filter's init-param properties based on $configFile to $webXmlToConfigure"
  applyWebXmlChangesFromFile "$webXmlToConfigure" "$configFile"
else
  echo "Web-configuration.properties file not provided. No changes to web.xml file."
fi
