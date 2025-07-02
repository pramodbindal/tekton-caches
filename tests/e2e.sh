#!/bin/bash

set -x
export KO_DOCKER_REPO=${KO_DOCKER_REPO:- ko.local}
ROOT="$(git rev-parse --show-toplevel)"

ko apply -R -f ${ROOT}/dev/step-action/

kubectl get stepAction cache-fetch -o jsonpath="{.spec.image}"
echo "Cache Fetch Step Action image is: $(kubectl get stepAction cache-fetch -o jsonpath="{.spec.image}")"

# Apply the GCS emulator configuration
kubectl apply -f "${ROOT}/tests/emulators/gcs-emulator.yaml"

# Wait for the deployment to be ready
echo "Waiting for GCS emulator deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/gcs-emulator -n tekton-pipelines

# Check the deployment status
if [ $? -eq 0 ]; then
    echo "GCS emulator deployment is ready"
else
    echo "Error: GCS emulator deployment failed to become ready within the timeout period"
    exit 1
fi

openssl rand -base64 20 > /tmp/test
kubectl delete secret creds --ignore-not-found
kubectl create secret generic creds   --from-literal=GCP_APPLICATION_CREDENTIALS=/tmp/test
kubectl delete pr --all
kubectl delete pipeline --all

