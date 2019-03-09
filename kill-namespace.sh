#!/bin/bash

set -eo pipefail

die() { echo "$*" 1>&2 ; exit 1; }

need() {
	which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

need "jq"
need "curl"
need "kubectl"

NAMESPACE="$1"
shift

test -n "$NAMESPACE" || die "Missing arguments: kill-ns <namespace>"

kubectl proxy &>/dev/null &
PROXY_PID=$!
killproxy () {
	kill $PROXY_PID
}
trap killproxy EXIT

sleep 3

kubectl get namespace "$NAMESPACE" -o json | jq 'del(.spec.finalizers[] | select("kubernetes"))' | curl -s -k -H "Content-Type: application/json" -X PUT -o /dev/null --data-binary @- http://localhost:8001/api/v1/namespaces/$NAMESPACE/finalize && echo "Killed namespace: $NAMESPACE"
