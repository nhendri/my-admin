#!/bin/bash

# by: Nick H
# runPlaybook script does the following:
#   - checks if Docker exists and errors with a condescending message if it doesn't
#   - checks if our required image exists and either builds it or warns of its absence if it does not
#   - does a simple validation of the .ssh config (simply checks if $HOME/.ssh/id_rsa and $HOME/.ssh/id_rsa.pub exist - doesn't try to validate them past that)
#   - if everything checks out, provides the docker run command that runs an ansible playbook with the capacity for the same syntax as the actual `ansible-playbook`
#           command (see https://docs.ansible.com/ansible/latest/user_guide/playbooks.html for more info.)

# To Do: Modify slightly to log out to configurable log path for noninteractive use

function checkDocker () {
    dockerVersion=$(docker --version 2> /dev/null)
    dockerPresent=$?
    if [ $dockerPresent -eq 0 ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"$dockerVersion installed\"}]\n"
    else
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"Exit Code $dockerPresent when trying to validate Docker Version - Docker may not be installed, or the Docker commands may not be in your path\"}]\n"
        exit 78
    fi
}

function buildControllerImage () {
    
    EXPECTED_ARGS=2
    if [ $# -ne $EXPECTED_ARGS ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"USAGE: $0 dockerImage Build/Alert\"}]\n"
        exit 65
    fi
    dockerImage=$1
    buildOrAlert=$2
    
    if [ ! "$(docker image ls $dockerImage | grep $dockerImage)" ]; then
        if [ $buildOrAlert == "A" ]; then
            printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"Image not found: $dockerImage - please build using the command 'docker build -t $dockerImage .' and run this script again.\"}]\n"
            exit 78
            elif [ $buildOrAlert == "B" ]; then
            printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [WARNING] [{\"message\":\"Image '$dockerImage' not found. Building.\"}]\n"
            # ffr - this little section here actually writes to the fs - probably not a great idea... #
            docker build -t $dockerImage . 2>buildResultError                                         #
            buildResultCode=$?                                                                        #
            buildResultMsg=$(cat buildResultError)                                                    #
            rm -f buildResultError                                                                    #
            # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
            if [ $buildResultCode -ne 0 ]; then
                printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"ERROR CREATING IMAGE $dockerImage: Code $buildResultCode with message '$buildResultMsg'\"}]\n"
                exit $buildResultCode
            fi
        else
            printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"buildOrAlert improperly set to $buildOrAlert\"}]\n"
            exit 65
        fi
    else
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"$dockerImage present...\"}]\n"
        echo "$dockerImage present..."
    fi
}

function checkSSH () {
    
    EXPECTED_ARGS=1
    
    if [ $# -ne $EXPECTED_ARGS ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"USAGE: $0 PUBLIC/PRIVATE\"}]\n"
        exit 65
    fi
    
    if [ $1 != "PUBLIC" ] && [ $1 != "public" ] && [ $1 != "PRIVATE" ] && [ $1 != "private" ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"$0 expects parameter to be PUBLIC for the public key or PRIVATE for the private key\"}]\n"
        exit 65
    fi
    
    pubPrivFlag=$1
    
    if [ $pubPrivFlag == "PUBLIC" ] || [ $pubPrivFlag == "public" ]; then
        rsaFile="id_rsa.pub"
        elif [ $pubPrivFlag == "PRIVATE" ] || [ $pubPrivFlag == "private" ]; then
        rsaFile="id_rsa"
    fi
    
    if [ ! -f $HOME/.ssh/$rsaFile ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"$rsaFile not found!\"}]\n"
        exit 78
        elif [ -f $HOME/.ssh/$rsaFile ]; then
        echo $HOME/.ssh/$rsaFile
    fi
}

function runPlaybook () {
    
    if [ $# -eq 0 ]; then
        echo -e "Please supply the parameters required to run your playbook. \n"
        echo -e "Example Usage: 'bash ./runPlaybook.sh -i inventory/hosts playbook.yml'\n"
        echo "where 'inventory/hosts' is the file for the playbook targets and"
        echo -e "'playbook.yml' is the name of the playbook being run...\n"
        echo -e "Visit 'https://docs.ansible.com/' for more information...\n"
        exit 65
    fi
    
    validationSuccess="ANSIBLE CONTROLLER ENV VALIDATION SUCCEEDED"
    validationFailed="ANSIBLE CONTROLLER ENV VALIDATION FAILED"
    
    resultDockerCheck=$(checkDocker)
    resultDockerCheckCode=$?
    if [ $resultDockerCheckCode -ne 0 ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"$validationFailed - $resultDockerCheck\"}]\n"
        exit $resultDockerCheckCode
    else
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"$validationSuccess - $resultDockerCheck\"}]\n"
    fi
    
    dockerImage="nickh/test-controller"
    #dockerImage="nickh/ansible-controller"
    buildControllerImage $dockerImage B # Change "B" to "A" to stop the
    # script with a warning rather than building the controller image
    resultImageCheckCode=$?
    if [ $resultImageCheckCode -ne 0 ]; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"$validationFailed - $resultImageCheck\"}]\n"
        exit $resultImageCheckCode
    else
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"$validationSuccess - $dockerImage built\"}]\n"
    fi
    
    resultPubCheck=$(checkSSH PUBLIC)
    checkPubSSHCode=$?
    resultPrivCheck=$(checkSSH PRIVATE)
    checkPrivSSHCode=$?
    if [ $checkPubSSHCode -eq 0 ] && [ $checkPrivSSHCode -eq 0 ] ; then
        printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [INFO] [{\"message\":\"$validationSuccess - Ansible Controller Host SSH Configured Properly...\"}]\n"
    else
        if [ $checkPubSSHCode -ne 0 ] && [ $checkPrivSSHCode -eq 0 ]; then
            printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"$validationFailed - Error With Public Key: $resultPubCheck\"}]\n"
            exit 78
            elif [ $checkPrivSSHCode -ne 0 ] && [ $checkPubSSHCode -eq 0 ]; then
            printf "[$(date '+%Y-%m-%d %H:%M:%S')] [ADMIN] [ERROR] [{\"message\":\"$validationFailed - Error With Private Key: $resultPrivCheck\"}]\n"
            exit 78
        fi
    fi
    
    docker run -it \
    --rm \
    -v $resultPrivCheck:/root/.ssh/id_rsa \
    -v $resultPubCheck:/root/.ssh/id_rsa.pub \
    -v $PWD/controller_files/ssh/config:/root/.ssh/config \
    -v $PWD/playbooks:/ansible/playbooks \
    $dockerImage "$@"
    
}

runPlaybook $@
