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
# kubectl apply -f k8s
kubectl apply -f k8s/client-cluster-ip-service.yaml
kubectl apply -f k8s/client-deployment.yaml
kubectl apply -f k8s/database-cluster-volume-claim.yaml
# kubectl apply -f k8s/gce-ingress-service.yml
kubectl apply -f k8s/postgres-cluster-ip-service.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/redis-cluster-ip-service.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/server-cluster-ip-service.yaml
kubectl apply -f k8s/server-deployment.yaml
kubectl apply -f k8s/worker-deployment.yaml

kubectl apply -f k8s/issuer.yaml
kubectl apply -f k8s/certificate.yaml
kubectl apply -f k8s/ingress-service.yaml

echo "set docker image imperatively .... "
kubectl set image deployments/server-deployment server=${$DOCKER_ID}/multi-server:${SHA}
kubectl set image deployments/client-deployment client=${$DOCKER_ID}/multi-client:${SHA}
kubectl set image deployments/worker-deployment worker=${$DOCKER_ID}/multi-worker:${SHA}

echo "deployment is done"
