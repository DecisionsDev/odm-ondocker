#!/bin/bash


if [ -n "$ENABLE_DECISION_ASSISTANT" ]
then
  if [[ $ENABLE_DECISION_ASSISTANT =~ "true" ]]
  then
    echo "Configure Decision Assistant Web App"
    cp webSecurity_DecisionAssistant.xml webSecurityDecisionAssistant.xml
  fi
fi



# End - Add DC Apps
