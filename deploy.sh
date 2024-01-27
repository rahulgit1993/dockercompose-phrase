#!/bin/bash

echo -e "Starting with Deployment script"

function upgrade_app {
    SERVICE_NAME=$1

echo -e "Building new docker image for $SERVICE_NAME"
# Build new Docker image for the specified service
docker-compose build "$SERVICE_NAME"

echo -e "stopping old containers"
# Stop old containers gracefully
OLD_CONTAINERS=$(docker ps --filter "name=${SERVICE_NAME}" --filter "status=running" --format "{{.ID}}")
docker-compose stop "$SERVICE_NAME"
echo $OLD_CONTAINERS

# Verify that the old containers have stopped
while [ $(docker ps --filter "name=${SERVICE_NAME}" --filter "status=running" -q | wc -l) -gt 0 ]; do
  sleep 2
done

echo -e "verifying old container have been stopped or not"

# Start new containers with zero-downtime
docker-compose up --detach --scale "$SERVICE_NAME"=2

echo -e "Starting new containers without downtime"

# Verify that the new containers are up and running
while [ $(docker ps --filter "name=${SERVICE_NAME}" --filter "status=running" -q | wc -l) -lt 2 ]; do
  sleep 2
done

echo -e "Verifying new containers are running or not"

# Stop and remove old containers that are not running
for CONTAINER in $OLD_CONTAINERS; do
echo $CONTAINER
        docker stop "$CONTAINER" >>/dev/null 2>&1
        docker rm "$CONTAINER" >>/dev/null 2>&1
done

echo -e "Tagging new image to latest ones"

# Tag new image as the latest one
docker tag "phrase-assignment-${SERVICE_NAME}:latest" "phrase-assignment-${SERVICE_NAME}:$(date +%Y%m%d%H%M%S)"

echo -e "Removing images retaining recent 3"

#To remove the images from local except the recent 3
docker images --format "{{.Repository}}:{{.Tag}}" | grep -iv "latest" | sort -r | tail -n +5 | xargs docker rmi >> /dev/null 2>&1

}

# Upgrade app1
upgrade_app "app1"

sleep 15
# Upgrade app2
upgrade_app "app2"

echo "Cleanup in Progress"
docker-compose up -d
echo -e ""waiting for 10 seconds
sleep 5
docker-compose up -d
echo " Upgrade for services completed successfully."