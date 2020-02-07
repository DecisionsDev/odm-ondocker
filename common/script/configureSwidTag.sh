#!/bin/bash

function removeSwidTag () {
        local swidtagToRemove=$1
        if [ -f $swidtagToRemove ]; then
                echo "remove $swidtagToRemove"
                rm $swidtagToRemove
        fi
}

if [ -n "$KubeVersion" ]; then
        if [[ $KubeVersion =~ "icp" ]] || [[ $KubeVersion =~ "ODM on K8s" ]]; then
                echo "ODM configuration : remove all DBAMC Swidtag"
                swidtagToRemove=ibm.com_IBM_Cloud_Pak_for_Automation*.swidtag
        else
                echo "DBAMC configuration : remove all ODM Swidtag"
                swidtagToRemove=ibm.com_IBM_ODM_*.swidtag
        fi

        removeSwidTag /config/apps/decisioncenter.war/META-INF/swidtag/$swidtagToRemove
        removeSwidTag /config/apps/decisionmodel.war/META-INF/swidtag/$swidtagToRemove
        removeSwidTag /config/apps/decisioncenter-api.war/META-INF/swidtag/$swidtagToRemove
        removeSwidTag /config/apps/teamserver.war/META-INF/swidtag/$swidtagToRemove

        removeSwidTag /config/apps/DecisionRunner.war/META-INF/swidtag/$swidtagToRemove
        removeSwidTag /config/apps/DecisionService.war/META-INF/swidtag/$swidtagToRemove
        removeSwidTag /config/apps/res.war/META-INF/swidtag/$swidtagToRemove
fi
