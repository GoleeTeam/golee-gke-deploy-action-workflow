#!/bin/sh -l

# public options
image_path=$1
platform=$2
repository=$3
environment=$4
region=$5

# internal variables
service=${repository##*/}

export USE_GKE_GCLOUD_AUTH_PLUGIN=True
echo -n $GCLOUD_SERVICE_ACCOUNT_KEYFILE >./gcloud-api-key.json
gcloud auth activate-service-account --key-file gcloud-api-key.json
gcloud config set project $GCLOUD_PROJECT

if [ "$platform" = "gke" ]; then
    echo "Deploy, platform: $platform"

    cluster="gle-$environment"
    namespace="$environment"
    gcloud container clusters get-credentials $cluster --zone=$region
    kubectl set image deployment $service $service=$image_path --namespace=$namespace
    kubectl rollout status deployment/$service --namespace=$namespace --timeout=300s
elif [ "$platform" = "cloud-run" ]; then
    echo "Deploy, platform: $platform"

    cloud_run_service="$service-$environment"
    gcloud run deploy $cloud_run_service --image=$image_path --region=$region
else
    echo "Unsupported platform: $platform"
    exit 1
fi
