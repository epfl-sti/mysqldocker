# mysqldocker

DISCLAIMER: this bash script is only for development purpose and should
not be used in a production environment.

## About
This script make easier the deployment of an MySQL environment in a development
environment.

## Usage
```
./mysqldocker.sh
This is a simple script to manage a MySQL docker container
  OPTIONS:
    - h/? : show this help
    - d   : dump the mysql_docker DB
    - r   : run the mysql_docker container with mysql_docker
    - k   : kill the mysql_docker container
    - e   : dump and stop the mysql_docker container
    - i   : interactively connect to the mysql_docker container
    - v   : verbose mode (set -x)
```

### Variables
  * `DOCKER_MYSQL_NAME`, default to: _mysql_docker_
  * `DOCKER_MYSQL_DB_NAME`, default to: _mysql_docker_
  * `DOCKER_MYSQL_ROOT_PASSWORD`, default to: _myverysecurepassword_
  * `DOCKER_MYSQL_USER`, default to: _mysql_docker_
  * `DOCKER_MYSQL_USER_PASSWORD`, default to: _myverysecurepassword_
  * `MYSQL_DIRECTORY_PATH`, default to: _$PWD_

These variables can be defined as you call the script, e.g. :
```
 DOCKER_MYSQL_NAME=mysql_docker \
 DOCKER_MYSQL_DB_NAME=mysql_docker \
 DOCKER_MYSQL_ROOT_PASSWORD=myverysecurepassword \
 DOCKER_MYSQL_USER=mysql_docker \
 DOCKER_MYSQL_USER_PASSWORD=myverysecurepassword \
 MYSQL_DIRECTORY_PATH=$PWD \
 ./mysqldocker.sh -d
```

## Tips
  * Use `docker logs mysql_docker`
  * In case of _"2002: Can't connect to local MySQL server through socket"_ or
  _"1045: Access denied for user 1045: Access denied for user"_:  
      1. wait a few seconds before retrying, in most case the mysqld service in
       the docker container is not ready  
      2. try to remove the `$MYSQL_DIRECTORY_PATH/mysql/data` directory
  * You can see the ENV variables in the docker container with:  
    `docker exec -it mysql_docker printenv`
  * You can query the mysql database directly from the host with:  
    `docker exec -it mysql_docker mysql -u root -pmyverysecurepassword -e "show databases; show characters set;"`;
  * You can define your own `my.cnf` in the `$MYSQL_DIRECTORY_PATH/mysql/conf.d` directory
  * All `*.sql` or `*.sh` in the `$MYSQL_DIRECTORY_PATH/mysql/initdb.d` will be
    executed as startup (**good way to initialize your db from a previous dump**).

## Thanks
  * The MySQL official docker repository: https://hub.docker.com/_/mysql/
  * Tips and tricks from [@besnik](https://github.com/besnik): https://github.com/besnik/tutorials/tree/master/docker-mysql
