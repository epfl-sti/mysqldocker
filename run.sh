#!/bin/bash
# https://hub.docker.com/_/mysql/
# https://github.com/besnik/tutorials/tree/master/docker-mysql
# Quick and dirty way to execute mysql command in the container:
#   docker exec -it mysql_docker mysql -u root -pmyverysecurepassword -e "show databases;";
#set -e -x

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

# Script's variables
: ${DOCKER_MYSQL_NAME:=mysql_docker}
: ${DOCKER_MYSQL_DB_NAME:=mysql_docker}
: ${DOCKER_MYSQL_ROOT_PASSWORD:=myverysecurepassword}
: ${DOCKER_MYSQL_USER:=mysql_docker}
: ${DOCKER_MYSQL_USER_PASSWORD:=myverysecurepassword}
: ${MYSQL_DIRECTORY_PATH:=$PWD}

# Make the MYSQL directory
# TODO: at some point you may want to remove the mysql (or at least the data)
#       directory. This is important if you change the variable, e.g. passwords.
mkdir -p $MYSQL_DIRECTORY_PATH/mysql/{conf.d,initdb.d,data,dumps}

# Show help function
showHelp() {
    echo "This is a simple script to manage a MySQL docker container"
    echo "  OPTIONS:"
    echo "    - h/? : show this help"
    echo "    - d   : dump the $DOCKER_MYSQL_DB_NAME DB"
    echo "    - r   : run the $DOCKER_MYSQL_NAME container with $DOCKER_MYSQL_DB_NAME"
    echo "    - k   : kill the $DOCKER_MYSQL_NAME container"
    echo "    - e   : dump and stop the $DOCKER_MYSQL_NAME container"
    echo "    - i   : interactively connect to the $DOCKER_MYSQL_NAME container"
}

# Show help in case of no opt
if [[ $# -eq 0 ]] ; then
    showHelp
    exit 0
fi

# Run the docker container
run() {
    docker run \
        --name $DOCKER_MYSQL_NAME \
        -e MYSQL_ROOT_PASSWORD=$DOCKER_MYSQL_ROOT_PASSWORD \
        -e MYSQL_DATABASE=$DOCKER_MYSQL_DB_NAME \
        -e MYSQL_USER=$DOCKER_MYSQL_USER \
        -e MYSQL_PASSWORD=$DOCKER_MYSQL_USER_PASSWORD \
        -v $MYSQL_DIRECTORY_PATH/mysql/data:/var/lib/mysql \
        -v $MYSQL_DIRECTORY_PATH/mysql/initdb.d:/docker-entrypoint-initdb.d \
        -d mysql:5
        #-v $MYSQL_DIRECTORY_PATH/mysql/conf.d:/etc/mysql/conf.d \
}

# Dump the DOCKER_MYSQL_DB_NAMEv using DOCKER_MYSQL_USER and DOCKER_MYSQL_USER_PASSWORD
dump() {
    DUMP_DATE=$(date +"%Y%m%d%H%M%S")
    DUMP_FILE=$MYSQL_DIRECTORY_PATH/mysql/dumps/$DUMP_DATE\_$DOCKER_MYSQL_DB_NAME\_dump.sql
    # The Root Way
    #docker exec $DOCKER_MYSQL_NAME \
    #    sh -c 'exec mysqldump --databases $MYSQL_DATABASE -uroot -p"$MYSQL_ROOT_PASSWORD"'> $DUMP_FILE
    # CLI: docker exec mysql_docker sh -c 'exec mysqldump --databases mysql_docker -uroot -p"$MYSQL_ROOT_PASSWORD"' > dump.sql

    # The user way
    docker exec $DOCKER_MYSQL_NAME \
        sh -c 'exec mysqldump --databases $MYSQL_DATABASE -u"$MYSQL_USER" -p"$MYSQL_PASSWORD"'> $DUMP_FILE

    head -5 $DUMP_FILE
    echo ""
    echo "Full dump: $DUMP_FILE"

    # NOTE: if error:
    #       mysqldump: Got error: 2002: Can't connect to local MySQL server
    #       through soket '/var/run/mysqld/mysqld.sock' (2) when trying to connect
    #       => wait for a few seconds, mysql service is not fully started in the
    #       container.
}

# Ensure the mysql's docker is stopped and removed
killc() {
    StateRunning=$(docker inspect $DOCKER_MYSQL_NAME | jq '.[0] | .State.Running')
    StateStatus=$(docker inspect $DOCKER_MYSQL_NAME | jq '.[0] | .State.Status')

    if [ "$StateRunning" = "true" ]; then
        echo "Stopping $DOCKER_MYSQL_NAME"
        docker stop $DOCKER_MYSQL_NAME #2>/dev/null
        docker rm $DOCKER_MYSQL_NAME
    fi

    if [ $StateStatus = \"exited\" ]; then
        echo "Removing $DOCKER_MYSQL_NAME"
        docker rm $DOCKER_MYSQL_NAME #2>/dev/null
    fi
}

# Interactive Shell
interactive() {

    # TODO docker inspect $DOCKER_MYSQL_NAME and run it if needed

    docker exec -it $DOCKER_MYSQL_NAME bash
}

# Menu cases
# --h: Help
# --d: Dump
# --r: Run
# --k: Stop
# --v: Verbose
# --i: Interactive
while getopts "h?drkeiv" opt; do
    case "$opt" in
    h|\?)
        showHelp
        exit 0
        ;;
    r)
        echo "mode: run"
        killc
        run
        ;;
    d)
        echo "mode: dump"
        dump
        ;;
    k)
        echo "mode: kill"
        killc
        ;;
    e)
        echo "mode: end"
        dump
        killc
        ;;
    i)
        echo "mode: interactive"
        interactive
        ;;
    v)
        verbose=1
        ;;
    esac
done

# debug mode
if [[ $verbose -eq 1 ]];then
  set -x
fi;

shift $((OPTIND-1))

[ "$1" = "--" ] && shift
