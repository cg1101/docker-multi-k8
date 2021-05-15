#!/bin/bash

echo "building docker images ... "

docker build -t "${DOCKER_ID}/multi-client:latest" \
             -t "${DOCKER_ID}/multi-client:${SHA}" \
             -f ./client/Dockerfile ./client
docker build -t "${DOCKER_ID}/multi-server:latest" \
             -t "${DOCKER_ID}/multi-server:${SHA}" \
             -f ./server/Dockerfile ./server
docker build -t "${DOCKER_ID}/multi-worker:latest" \
             -t "${DOCKER_ID}/multi-worker:${SHA}" \
             -f ./worker/Dockerfile ./worker

echo "publishing docker images to docker hub ... "
docker push "${DOCKER_ID}/multi-client:latest"
docker push "${DOCKER_ID}/multi-client:${SHA}"
docker push "${DOCKER_ID}/multi-server:latest"
docker push "${DOCKER_ID}/multi-server:${SHA}"
docker push "${DOCKER_ID}/multi-worker:latest"
docker push "${DOCKER_ID}/multi-worker:${SHA}"

echo "update kubernetes ... "
kubectl apply -f k8s/*.yaml

echo "set docker image imperatively .... "
kubectl set image deployments/server-deploy server={$DOCKER_ID}/multi-server:${SHA}
kubectl set image deployments/client-deploy client={$DOCKER_ID}/multi-client:${SHA}
kubectl set image deployments/worker-deploy worker={$DOCKER_ID}/multi-worker:${SHA}

echo "deployment is done"
