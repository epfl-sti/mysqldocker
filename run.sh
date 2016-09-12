#!/bin/bash
# https://hub.docker.com/_/mysql/
# https://github.com/besnik/tutorials/tree/master/docker-mysql
set -e -x

: ${DOCKER_MYSQL_NAME:=mysql_docker}
: ${DOCKER_MYSQL_DB_NAME:=mysql_docker}
: ${DOCKER_MYSQL_ROOT_PASSWORD:=myverysecurepassword}
: ${DOCKER_MYSQL_USER:=mysql_docker}
: ${DOCKER_MYSQL_USER_PASSWORD:=myverysecurepassword}
: ${MYSQL_DIRECTORY_PATH:=$PWD}

# Make the MYSQL directory
mkdir -p $MYSQL_DIRECTORY_PATH/mysql/{conf.d,initdb.d,data,dumps}

# Ensure the mysql's docker is stopped and removed
StateStatus=$(docker inspect $DOCKER_MYSQL_NAME | jq '.[0] | .State.Status')
StateRunning=$(docker inspect $DOCKER_MYSQL_NAME | jq '.[0] | .State.Running')

if [ "$StateRunning" = "true" ]; then
    echo "Stopping $DOCKER_MYSQL_NAME"
    docker stop $DOCKER_MYSQL_NAME #2>/dev/null
fi

if [ $StateStatus = \"exited\" ]; then
    echo "Removing $DOCKER_MYSQL_NAME"
    docker rm $DOCKER_MYSQL_NAME #2>/dev/null
fi

# Run the docker container
docker run \
    --name $DOCKER_MYSQL_NAME \
    -e MYSQL_ROOT_PASSWORD=$DOCKER_MYSQL_ROOT_PASSWORD \
    -e MYSQL_DATABASE=$DOCKER_MYSQL_DB_NAME \
    -e MYSQL_USER=$DOCKER_MYSQL_USER \
    -e MYSQL_PASSWORD=$DOCKER_MYSQL_USER_PASSWORD \
    -v $MYSQL_DIRECTORY_PATH/mysql/conf.d:/etc/mysql/conf.d \
	-v $MYSQL_DIRECTORY_PATH/mysql/initdb.d:/docker-entrypoint-initdb.d \
    -v $MYSQL_DIRECTORY_PATH/mysql/data:/var/lib/mysql \
    -d mysql:5

# docker inspect $DOCKER_MYSQL_NAME
# Interactive Shell
# docker exec -it $DOCKER_MYSQL_NAME bash

# Mysql Dump
#docker exec $DOCKER_MYSQL_NAME \
    #sh -c 'exec mysqldump --databases $DOCKER_MYSQL_DB_NAME -uroot -p"$MYSQL_ROOT_PASSWORD"' > $MYSQL_DIRECTORY_PATH/dumps
