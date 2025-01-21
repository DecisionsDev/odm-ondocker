#!/bin/bash

# compare two versions $1 and $2
# return 0 if $1 equals to $2
# return 1 if $1 is greater than $2
# return 2 if $1 is less than $2
function compareVersion () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)

    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return -1
}

# execute the feature script
# $1 feature directory
# $2 feature name
function runFeatureScript() {
  local featureDir=$1
  local featureName=$2
  local featureScript="$featureDir/$featureName.sh"
  $featureScript
}


# load features from the feature directory containing features.properties and feature scripts
# argument $1 the feature dir
# argument $2 the current version
function loadFeatures() {
  local featureDir=$1
  local featureFile="$featureDir/features.properties"
  local currentVersion=$2

  if [ ! "$featureDir" ]
  then
    echo "ERROR: Please specify the feature directory with the first argument to load features."
    return 1
  fi

  if [ ! "$currentVersion" ]
  then
    echo "ERROR: Current version is unknown, skip loading features."
    return 1
  fi

  if [ -f "$featureFile" ]
  then
    echo "current version $currentVersion"
    echo "loading features from $featureFile ..."

    while IFS='=' read -r key value
    do
      local version=$key
      local features=(${value//,/ })

      # compare the current version with the feature version
      compareVersion $currentVersion $version

      # if the feature version is less or equal to the current version, load the features
      if [ $? -le 1 ]
      then
        echo "loading features of $version ..."

        local feature
        for feature in "${features[@]}"
        do
          runFeatureScript $featureDir $feature
        done
      fi

    done < "$featureFile"

  else
    echo "$featureFile not found."
  fi
}

if [ ! "$1" ]
then
  echo "ERROR: Please specify feature directory."
  return 1
fi

# $1 feature directory
export odmVersion=$($SCRIPT/extractODMVersion.sh)
echo "Load Feature for ODM Version : $odmVersion"
loadFeatures $1 $odmVersion
