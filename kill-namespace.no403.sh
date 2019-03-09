#!/bin/bash

set -eo pipefail

die() { echo "$*" 1>&2 ; exit 1; }

need() {
	which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

NAMESPACE="$1"
kubectl proxy & \
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' > temp.json

curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize

rm temp.json