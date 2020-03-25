#!/bin/bash

## By: Nick H
## Description: This script sets up my single-host docker-compose monitoring stack. Is it production ready? No. But, are we using it? Why, yes... :)
## Steps
##  - Start ElasticSearch and Kibana
##  - Poll the ElasticSearch stdout for something that lets me know I can start Elastalert (probably the status changed to green thing)
##  - TODO: Meanwhile, somehow check if I have a letsencrypt cert or my own or no cert and if so, run the certbot script NONINTERACTIVELY
##    - and maybe with a flag to do it or not
## - To Do: do all this with an eye towards ansible controller doing it not a person directly :D
## - To Do: Modify slightly to log out to configurable log path for noninteractive use

function checkDockerDep () {
    dockerVersion=$(docker --version 2> /dev/null)
    dockerPresent=$?
    if [ $dockerPresent -eq 0 ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"$dockerVersion installed\"}]\n"
    else
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"Exit Code $dockerPresent when trying to validate Docker Version - Docker may not be installed, or the Docker commands may not be in your path\"}]\n"
        exit 78
    fi
    
    dockerComposeVersion=$(docker-compose -v 2> /dev/null)
    dockerComposePresent=$?
    if [ $dockerComposePresent -eq 0 ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"$dockerComposeVersion installed\"}]\n"
    else
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"Exit Code $dockerComposePresent when trying to validate Docker-Compose Version -\n  Docker-Compose may not be installed, or the Docker-Compose commands may not be in your path\"}]\n"
        exit 78
    fi
}

pollForService () {
    EXPECTED_ARGS=2
    
    if [ $# -ne $EXPECTED_ARGS ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"USAGE: $0 SERVICENAME TARGETPHRASE\"}]\n"
        exit 65
    fi
    
    SERVICENAME=$1
    TARGETPHRASE=$2
    
    printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"Waiting for $SERVICENAME to initialize\"}]\n"
    while true; do
        # Add a status dot.... something to do with \r\033[K - see https://stackoverflow.com/questions/2388090/how-to-delete-and-replace-last-line-in-the-terminal-using-bash
        docker-compose logs $SERVICENAME
        if [[ $(docker-compose logs --tail 1 $SERVICENAME) == **"$TARGETPHRASE"** ]]; then
            printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"$SERVICENAME is up!\"}]\n"
            break
        fi
        sleep 1
        docker-compose logs --tail 1 $SERVICENAME
    done
}

init () {
    printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"Checking Docker Dependencies...\"}]\n"
    checkDockerDep
    printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"Initializing Elasticsearch, Kibana...\"}]\n"
    docker-compose up -d elasticsearch kibana
    pollForService "elasticsearch" "Cluster health status changed from [YELLOW] to [GREEN]"
    docker-compose up -d elastalert elastichq
    pollForService "kibana" "Status changed from yellow to green - Ready"
    docker-compose ps
}

init