#!/usr/bin/env bash

# Setup default log redirect location
log_location="/dev/stdout"

# Setup default environment name
environment_name="local"

# Setup default state for logging_enabled
logging_enabled="false"

# Parse command line arguments
while getopts "e:lL:" opt; do
    case "$opt" in
        e) environment_name="$OPTARG" ;;
        l) logging_enabled="true" ;;
        L) log_location="$OPTARG" ;;
        *) echo "Usage: $0 [-e environment_name] [-l log_file]" ;;
    esac
done

# Check if logging_enabled is still false, if so, set the log_location to /dev/null
if [[ "$logging_enabled" == "false" ]]; then
    log_location="/dev/null"
fi

# Create the argocd namespace
kubectl create namespace argocd &> "$log_location" || true

# Install custom ArgoCD chart (includes root application resource)
if ! helm install argocd . -n argocd -f values.yaml --set environmentName="$environment_name" &> "$log_location" ; then
    echo "Failed to install ArgoCD"
    exit 1
fi

echo
echo "Waiting for the argocd-server deployment to be ready"
if ! kubectl rollout status deployment/argocd-server -n argocd --timeout=120s &> "$log_location" ; then
    echo "argocd-server deployment failed to become ready in allotted time"
    exit 1
fi

# Establish port forwarding of argocd-server service
if kubectl port-forward service/argocd-server -n argocd 8080:80 &> "$log_location" & 
then
    pf_pid=$!
else
    echo "Failed to establish port forwarding of argocd-server service"
    exit 1
fi

# Retrieve the admin user's password
if ! admin_password=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d &> "$log_location") ; then
    echo "Failed to retrieve admin user's password"
    exit 1
fi

# Open ArgoCD Web UI in browser
if ! open http://localhost:8080 ; then
    echo "Failed to open ArgoCD Web UI in browser"
    exit 1
fi

echo "ArgoCD installed successfully"
echo "Admin user's password: $admin_password"
echo
echo "Press Ctrl+C to stop port forwarding and exit this script"

wait "$pf_pid"
