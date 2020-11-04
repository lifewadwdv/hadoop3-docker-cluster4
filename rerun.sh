#!/usr/bin/env bash

docker rm $(docker stop -f $(docker ps -aq))

echo "Y" | docker system prune

docker-compose up -d