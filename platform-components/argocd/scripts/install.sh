#!/usr/bin/env bash

#
# Setup default values for script variables
#
log_location="/dev/stdout"
environment_name="local"
quiet="false"
namespace="platform"

#
# Parse command line arguments
#
while getopts "e:l:n:q" opt; do
    case "$opt" in
        e) environment_name="$OPTARG" ;;
        l) log_location="$OPTARG" ;;
        q) quiet="true" ;;
        n) namespace="$OPTARG" ;;
        *) echo "Usage: $0 [-e environment_name] [-l log_file] [-n namespace]" ;;
    esac
done

#
# Check if quiet is true, if so, overwrite the log_location to /dev/null
#
if [[ "$quiet" == "true" ]]; then
    log_location="/dev/null"
fi

#
# Check if the specified namespace doesn't exist, if so, create it
#
if ! kubectl get namespace "$namespace" &> "$log_location" ; then
    kubectl create namespace "$namespace" &> "$log_location" || {
        echo "Failed to create namespace $namespace"
        exit 1
    }
fi

#
# Install custom ArgoCD chart (includes root application resource)
#
if ! helm upgrade argocd . --install -n "$namespace" -f values.yaml --set environmentName="$environment_name" &> "$log_location" ; then
    echo "Failed to install/upgrade ArgoCD"
    exit 1
fi

echo
echo "Waiting for the ArgoCD server to be ready"
if ! kubectl rollout status deployment/argocd-server -n "$namespace" --timeout=120s &> "$log_location" ; then
    echo "argocd-server deployment failed to become ready in allotted time"
    exit 1
fi

# Establish port forwarding of argocd-server service
if kubectl port-forward service/argocd-server -n "$namespace" 3080:443 &> "$log_location" & 
then
    pf_pid=$!
else
    echo "Failed to establish port forwarding of ArgoCD server"
    exit 1
fi

# Retrieve the admin user's password
if ! admin_password="$(kubectl get secret argocd-initial-admin-secret -n "$namespace" -o jsonpath="{.data.password}" | base64 -d)" ; then
    echo "Failed to retrieve ArgoCD admin's password"
    exit 1
fi

# Open ArgoCD Web UI in browser
if ! open https://localhost:3080 ; then
    echo "Failed to open ArgoCD Web UI in browser: https://localhost:3080"
    echo
fi

echo "ArgoCD installed successfully"
echo "Admin user's password: $admin_password"
echo
echo "Press Ctrl+C to stop port forwarding and exit this script"

wait "$pf_pid"
