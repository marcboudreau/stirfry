# platform-components / argocd

The argocd component deploys Argo CD to manage deploying all of the other workloads into the Kubernetes cluster.

## Deployment

To deploy ArgoCD, the **argocd** namespace must first be created.

```
$ kubectl create namespace argocd
```

Then, Helm can be used to install ArgoCD.

```
$ helm install argocd . -n argocd -f values.yaml --set environmentName=<name_of_the_environment>
```

## Usage

To access the ArgoCD Web UI, the **argocd-server** service's port needs to be forwarded to the workstation.

```
$ kubectl port-forward service/argocd-server -n argocd 8080:80 &
$ open http://localhost:8080

```

The ArgoCD Web UI will prompt for a username and password. The username is `admin`. The password is randomly
generated when ArgoCD is installed. To obtain the randomly generated password, run the following command:

```
$ kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```
