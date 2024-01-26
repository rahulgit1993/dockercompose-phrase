#!/bin/bash

## To update it as per the service requirement pass argument ./deploy.sh app 
# Parse command-line arguments
#if [ $# -eq 0 ]; then
#    echo "Usage: $0 SERVICE_NAME"
#    exit 1
#fi
#SERVICE_NAME=$1

function upgrade_app {
    SERVICE_NAME=$1

#SERVICE_NAME=app1

# Check if service exists in docker-compose.yml
#if ! grep -q "^\s*$SERVICE_NAME:" docker-compose.yml; then
#    echo "Error: Service '$SERVICE_NAME' not found in docker-compose.yml"
#    exit 1
#fi

# Get path to Dockerfile for the specified service
DOCKERFILE_PATH=$(grep -A 1 "^\s*$SERVICE_NAME:" docker-compose.yml | grep "dockerfile:" | awk '{print $2}')
echo -e "Displaying dockerile path"
echo $DOCKERFILE_PATH
# Update Dockerfile if necessary

if [ -f "$DOCKERFILE_PATH.in" ]; then
    echo "Updating Dockerfile for $SERVICE_NAME..."
    envsubst < "$DOCKERFILE_PATH.in" > "$DOCKERFILE_PATH"
fi

echo -e "Building new docker image"
# Build new Docker image for the specified service
docker-compose build "$SERVICE_NAME"

echo -e "stopping old containers"
# Stop old containers gracefully
OLD_CONTAINERS=$(docker ps --filter "name=${SERVICE_NAME}" --filter "status=running" --format "{{.ID}}")
docker-compose stop "$SERVICE_NAME"
echo $OLD_CONTAINERS

echo -e "Stopped old ones"
# Verify that the old containers have stopped
while [ $(docker ps --filter "name=${SERVICE_NAME}" --filter "status=running" -q | wc -l) -gt 0 ]; do
  sleep 1
done

echo -e "verifying old container have been stopped or not"

# Start new containers with zero-downtime
docker-compose up --detach --scale "$SERVICE_NAME"=2

echo -e "Starting new containers without downtime"

# Verify that the new containers are up and running
while [ $(docker ps --filter "name=${SERVICE_NAME}" --filter "status=running" -q | wc -l) -lt 2 ]; do
  sleep 1
done

echo -e "Verifying new containers are running or not"

# Stop and remove old containers that are not running
for CONTAINER in $OLD_CONTAINERS; do
echo $CONTAINER
    #	if [ $(docker inspect --format '{{.State.Status}}' "$CONTAINER") != "running" ]; then
        docker stop "$CONTAINER" >>/dev/null 2>&1
        docker rm "$CONTAINER" >>/dev/null 2>&1 
#    fi
done

echo -e "Tagging new image to latest ones"

# Tag new image as the latest one
docker tag "phrase-assignment-${SERVICE_NAME}:latest" "phrase-assignment-${SERVICE_NAME}:$(date +%Y%m%d%H%M%S)"
#docker tag "${SERVICE_NAME}:latest" "${SERVICE_NAME}:$(date +%Y%m%d%H%M%S)"

echo -e "Removing images retaining recent 3"

#To remove the images from local except the recent 3
docker images --format "{{.Repository}}:{{.Tag}}" | grep -iv "latest" | sort -r | tail -n +5 | xargs docker rmi >> /dev/null 2>&1

# Push new image to a Docker registry (optional)
# docker push "${SERVICE_NAME}:latest"
# docker push "${SERVICE_NAME}:$(date +%Y%m%d%H%M%S)"
#echo "$SERVICE_NAME upgrade completed successfully."
}

# Upgrade app1
upgrade_app "app1"

sleep 20
# Upgrade app2
upgrade_app "app2"

#echo "Zero-downtime upgrade for both services completed successfully."
echo "Cleanup in Progress"
docker-compose up -d
echo -e ""waiting for 10 seconds

docker-compose up -d
sleep 5
echo " Upgrade for services completed successfully."
