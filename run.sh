#!/bin/bash

docker rm $(docker stop -f $(docker ps -aq))

docker rmi -f $(docker images -aq)

echo "Y" | docker system prune

echo "Y" | ssh-keygen -t rsa -P "" -f id_rsa

docker build -f ./Dockerfile . -t lifewadwdv/hadoop_cluster

# docker-compose up -d
