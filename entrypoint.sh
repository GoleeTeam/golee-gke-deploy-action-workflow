#!/bin/sh -l


INPUT_DEPLOYMENT_NAME=${INPUT_DEPLOYMENT_NAME##*/}

echo -n $GCLOUD_SERVICE_ACCOUNT_KEYFILE > ./gcloud-api-key.json
gcloud auth activate-service-account --key-file gcloud-api-key.json
gcloud config set project $GCLOUD_PROJECT

gcloud components install gke-gcloud-auth-plugin

gcloud container clusters get-credentials $INPUT_CLUSTER_NAME --zone=$INPUT_CLUSTER_ZONE
kubectl set image deployment $INPUT_DEPLOYMENT_NAME $INPUT_DEPLOYMENT_NAME=$INPUT_IMAGE_PATH --namespace=$INPUT_DEPLOYMENT_NAMESPACE
