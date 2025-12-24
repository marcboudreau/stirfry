# platform-components / argocd

The argocd component deploys Argo CD to manage deploying all of the other workloads into the Kubernetes cluster.

## Deployment

ArgoCD is installed, by default, in the **default** namespace along with all other resources. On local environments, a script is provided to execute all of the necessary commands and provide access to the ArgoCD web UI.

```bash
./scripts/install.sh
```

This script will ensure that the **default** namespace exists and then it will install/upgrade this Helm chart in that namespace. After that, it waits for the server to be ready and then establishes a port-forwarding tunnel to the local port 3080, retrieves and displays the admin user's password, and opens a browser window at the https://localhost:3080 address.

#### Additional Script Options

* **e** - specifies a different environment name; this is affects which _*-values.yaml_ files get included in the ArgoCD applications
* **l** - specifies a different file to receive command output
* **n** - specifies a different namespace name
* **q** - runs the script in quiet mode; most command output is squelched

