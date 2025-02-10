#!/bin/bash


if [ -n "$ENABLE_DECISION_ASSISTANT" ]
then
  if [[ $ENABLE_DECISION_ASSISTANT =~ "true" ]]
  then
    echo "Configure Decision Assistant Web App"
    cp /config/decisionassistant/webSecurityDecisionAssistant.xml /config/webSecurityDecisionAssistant.xml

    cp /config/decisionassistant/decisionassistant.properties /config/apps/decision-assistant.war/WEB-INF/classes/genai.properties
  fi
fi



# End - Add DC Apps
