if [ -n "$KubeVersion" ]; then
        if [ "$KubeVersion" = "DBAMC" ]; then
                echo "DBAMC configuration : remove all ODM Swidtag"
                swidtagToRemove=ibm.com_IBM_ODM_*.swidtag
        else
                echo "ODM configuration : remove all DBAMC Swidtag"
                swidtagToRemove=ibm.com_IBM_Digital_Business_Automation_for_Multicloud*.swidtag
        fi

        if [ -f /config/apps/decisioncenter.war/META-INF/swidtag/$swidtagToRemove ]; then
                echo "remove /config/apps/decisioncenter.war/META-INF/swidtag/$swidtagToRemove"
                rm /config/apps/decisioncenter.war/META-INF/swidtag/$swidtagToRemove
        fi
        if [ -f /config/apps/decisioncenter-api.war/META-INF/swidtag/$swidtagToRemove ]; then
                echo "remove /config/apps/decisioncenter-api.war/META-INF/swidtag/$swidtagToRemove"
                rm /config/apps/decisioncenter-api.war/META-INF/swidtag/$swidtagToRemove
        fi
        if [ -f /config/apps/teamserver.war/META-INF/swidtag/$swidtagToRemove ]; then
                echo "remove /config/apps/teamserver.war/META-INF/swidtag/$swidtagToRemove"
                rm /config/apps/teamserver.war/META-INF/swidtag/$swidtagToRemove
        fi

        if [ -f /config/apps/DecisionRunner.war/META-INF/swidtag/$swidtagToRemove ]; then
                echo "remove /config/apps/DecisionRunner.war/META-INF/swidtag/$swidtagToRemove"
                rm /config/apps/DecisionRunner.war/META-INF/swidtag/$swidtagToRemove
        fi

        if [ -f /config/apps/DecisionService.war/META-INF/swidtag/$swidtagToRemove ]; then
                echo "remove /config/apps/DecisionService.war/META-INF/swidtag/$swidtagToRemove"
                rm /config/apps/DecisionService.war/META-INF/swidtag/$swidtagToRemove
        fi

        if [ -f /config/apps/res.war/META-INF/swidtag/$swidtagToRemove ]; then
                echo "remove /config/apps/res.war/META-INF/swidtag/$swidtagToRemove"
                rm /config/apps/res.war/META-INF/swidtag/$swidtagToRemove
        fi

fi
