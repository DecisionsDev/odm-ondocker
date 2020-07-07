#!/bin/bash

function removeSwidTag () {
        local swidtagToRemove=$1
        if [ -f "$swidtagToRemove" ]; then
                echo "remove $swidtagToRemove"
                rm "$swidtagToRemove"
        fi
}

function removeAllSwidTag () {
	local swidtagToRemove=$1
        removeSwidTag "/config/apps/decisioncenter.war/META-INF/swidtag/$swidtagToRemove"
        removeSwidTag "/config/apps/decisionmodel.war/META-INF/swidtag/$swidtagToRemove"
        removeSwidTag "/config/apps/decisioncenter-api.war/META-INF/swidtag/$swidtagToRemove"
        removeSwidTag "/config/apps/teamserver.war/META-INF/swidtag/$swidtagToRemove"

        removeSwidTag "/config/apps/DecisionRunner.war/META-INF/swidtag/$swidtagToRemove"
        removeSwidTag "/config/apps/DecisionService.war/META-INF/swidtag/$swidtagToRemove"
        removeSwidTag "/config/apps/res.war/META-INF/swidtag/$swidtagToRemove"
}

if [ -n "$KubeVersion" ]; then
        if [[ $KubeVersion =~ "icp" ]] || [[ $KubeVersion =~ "ODM on K8s" ]]; then
                echo "ODM configuration : remove all DBAMC Swidtag"
		removeAllSwidTag ibm.com_Operational_Decision_Manager_Containers_-_CP4Auto-*.swidtag
		removeAllSwidTag ibm.com_Operational_Decision_Manager_Containers_-_CP4Auto_-_Non_Prod-*.swidtag
        else
		if [ -n "$DEPLOY_FOR_PRODUCTION" ]; then
        		if [[ "$DEPLOY_FOR_PRODUCTION" == "TRUE" ]]; then
                		echo "DEPLOY_FOR_PRODUCTION is true then DBAMC production configuration : remove DBAMC non production Swidtag"
                		removeAllSwidTag ibm.com_Operational_Decision_Manager_Containers_-_CP4Auto_-_Non_Prod-*.swidtag
        		else
                		echo "DEPLOY_FOR_PRODUCTION is false then DBAMC non production configuration : remove DBAMC production Swidtag"
                		removeAllSwidTag ibm.com_Operational_Decision_Manager_Containers_-_CP4Auto-*.swidtag
        		fi
		else
			echo "DEPLOY_FOR_PRODUCTION not set then DBAMC production configuration : remove DBAMC non production Swidtag"
        		removeAllSwidTag ibm.com_Operational_Decision_Manager_Containers_-_CP4Auto_-_Non_Prod-*.swidtag
                fi

                echo "DBAMC configuration : remove all ODM Swidtag"
		removeAllSwidTag ibm.com_IBM_ODM_*.swidtag
        fi
fi
