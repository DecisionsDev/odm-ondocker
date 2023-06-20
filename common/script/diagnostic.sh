#!/bin/bash

echo "Run Database Connection Check"

if [ -s "/config/datasource.xml" ];
  then
     SERVER_NAME=$(grep serverName=\" /config/datasource.xml | cut -d'"' -f 2 )
     PORT_NUMBER=$(grep portNumber=\" /config/datasource.xml | cut -d'"' -f 2 )
else
if [[ -s "/config/apps/decisioncenter.war" && -s "/config/customdatasource/datasource-dc.xml" ]];
  then
     SERVER_NAME=$(grep serverName=\" /config/customdatasource/datasource-dc.xml | cut -d'"' -f 2 )
     PORT_NUMBER=$(grep portNumber=\" /config/customdatasource/datasource-dc.xml | cut -d'"' -f 2 )

else
if [ -s "/config/customdatasource/datasource-ds.xml" ];
  then
     SERVER_NAME=$(grep serverName=\" /config/customdatasource/datasource-ds.xml | cut -d'"' -f 2 )
     PORT_NUMBER=$(grep portNumber=\" /config/customdatasource/datasource-ds.xml | cut -d'"' -f 2 )
fi
fi
fi

if [[ -n "$SERVER_NAME" && -n "$PORT_NUMBER" ]];
then
     echo "Check Connection to $SERVER_NAME:$PORT_NUMBER"
     curl -k -v -w " DNS: %{time_namelookup}s \n Connect: %{time_connect}s \n AppConnect: %{time_appconnect}s \n StartTransfer: %{time_starttransfer}s \n Total time: %{time_total}s \n Size download: %{size_download} \n Size upload: %{size_upload} \n Speed download: %{speed_download}/s \n Speed upload: %{speed_upload}/s \n Response code: %{response_code}\n" $SERVER_NAME:$PORT_NUMBER
else
    echo "Problem to find Database SERVER_NAME or PORT_NUMBER"
fi

echo " "
echo "****************************************************"
echo " "

if [ -s "/config/apps/decisioncenter.war" ];
then
   echo "Run HealtCheck on Decision Center"
   HEALTH_CHECK=decisioncenter/healthCheck
   HTTP_PORT=9060
fi

if [ -s "/config/apps/res.war" ];
then
   echo "Run HealtCheck on Decision Server Console"
   HEALTH_CHECK=res/login.jsf
   HTTP_PORT=9080
fi

if [ -s "/config/apps/DecisionRunner.war" ];
then
   echo "Run HealtCheck on Decision Runner"
   HEALTH_CHECK=DecisionRunner/
   HTTP_PORT=9080
fi

if [[ ! -s "/config/apps/res.war" ]];then
if [[ -s "/config/apps/DecisionService.war" ]];then
   echo "Run HealthCheck on Decision Server Runtime"
   HEALTH_CHECK=DecisionService/
   HTTP_PORT=9080
fi
fi

if [ -n "$HEALTH_CHECK" ];
then
   if [ -n "$ODM_CONTEXT_ROOT" ];
   then
      CHECK_URL=http://localhost:"$HTTP_PORT""$ODM_CONTEXT_ROOT"/"$HEALTH_CHECK"
   else
      CHECK_URL=http://localhost:"$HTTP_PORT"/"$HEALTH_CHECK"
   fi
   echo "CHECK_URL: $CHECK_URL"
else
   echo "Problem to find the Application HealthCheck"
fi

if [[ -n "$CHECK_URL" ]];
then
   curl -k -v -w " DNS: %{time_namelookup}s \n Connect: %{time_connect}s \n AppConnect: %{time_appconnect}s \n StartTransfer: %{time_starttransfer}s \n Total time: %{time_total}s \n Size download: %{size_download} \n Size upload: %{size_upload} \n Speed download: %{speed_download}/s \n Speed upload: %{speed_upload}/s \n Response code: %{response_code}\n" $CHECK_URL


   echo "****************************************************"
fi
