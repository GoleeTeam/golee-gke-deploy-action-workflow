#!/bin/sh -l

INPUT_DEPLOYMENT_NAME=${INPUT_DEPLOYMENT_NAME##*/}
PLATFORM="${INPUT_PLATFORM:-gke}"

export USE_GKE_GCLOUD_AUTH_PLUGIN=True
echo -n $GCLOUD_SERVICE_ACCOUNT_KEYFILE > ./gcloud-api-key.json
gcloud auth activate-service-account --key-file gcloud-api-key.json
gcloud config set project $GCLOUD_PROJECT   

if [ "$PLATFORM" = "gke" ]; then
    echo "Deploy, platform: $PLATFORM"
    gcloud container clusters get-credentials $INPUT_CLUSTER_NAME --zone=$INPUT_CLUSTER_ZONE
    kubectl set image deployment $INPUT_DEPLOYMENT_NAME $INPUT_DEPLOYMENT_NAME=$INPUT_IMAGE_PATH --namespace=$INPUT_DEPLOYMENT_NAMESPACE
    kubectl rollout status deployment/$INPUT_DEPLOYMENT_NAME --namespace=$INPUT_DEPLOYMENT_NAMESPACE --timeout=300s
elif [ "$PLATFORM" = "cloud-run" ]; then
    echo "Deploy, platform: $PLATFORM"
    gcloud run deploy $INPUT_DEPLOYMENT_NAME --image=$INPUT_IMAGE_PATH --region=$INPUT_CLUSTER_ZONE
else
    echo "Unsupported platform: $PLATFORM"
    exit 1
fi