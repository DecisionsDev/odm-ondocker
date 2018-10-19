#!/bin/sh


export ret=0

wait_for_url () {
    echo "Testing url $1 availability."

    if [ $# -ge 3 ]
    then
      echo "authentication is enabled."
      auth="-u $2:$3"
    fi

    i=0
    until $(curl $auth --connect-timeout 180 --output /dev/null --silent --head --fail $1); do
        i=$((i+1))
        if [ $i -gt 10 ]; then
            printf "X\n"
            ret=1
            return
        fi
        printf '.'
        sleep 15
    done

    printf "OK\n"
}

check_for_docker_url () {
    dockerimg=$1
    dockerurl=$2

    echo "Test $dockerurl availability in $dockerimg image."

    docker exec -u 0:0 -ti $dockerimg bash -c " \
        apt-get -qq update && \
        apt-get -qq install -y iputils-ping && \
        ping -q -c5 $dockerurl > /dev/null && \
        if [ $? -eq 0 ] ; then \
            echo \"OK: $dockerimg\"; \
        else \
            echo \"KO: $dockerimg\" \
            exit 1; \
        fi"
    if [ $? -ne 0 ]; then
        ret=1
    fi
}


wait_for_url http://localhost:9070/DecisionRunner
wait_for_url http://localhost:9090/DecisionService resExecutor resExecutor
wait_for_url http://localhost:9060/decisioncenter
wait_for_url http://localhost:9060/teamserver
wait_for_url http://localhost:9080/res
wait_for_url http://localhost:9080/DecisionService resExecutor resExecutor

check_for_docker_url odm-ondocker_odm-decisionrunner_1        dbserver
check_for_docker_url odm-ondocker_odm-decisionserverruntime_1 dbserver
check_for_docker_url odm-ondocker_odm-decisionserverconsole_1 dbserver
check_for_docker_url odm-ondocker_odm-decisioncenter_1        dbserver
check_for_docker_url odm-ondocker_odm-decisioncenter_1        odm-decisionrunner
check_for_docker_url odm-ondocker_odm-decisioncenter_1        odm-decisionserverconsole
check_for_docker_url odm-ondocker_odm-decisionserverruntime_1 odm-decisionserverconsole


exit $ret
