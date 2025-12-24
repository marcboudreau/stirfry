stirfry / platform-components
=============================

This directory contains the configuration used to manage platform components in the Kubernetes cluster. Each subdirectory contained within this directory contains a Helm chart for a specific platform component.

Platform Components
-------------------

### argocd

The **argocd** platform component is a bit special because its Helm chart installs ArgoCD (the _charts/_ subdirectory and _templates/_ subdirectory), but it also installs ArgoCD applications in the Kubernetes cluster for all of the other components (the _argocd-applications/templates_ subdirectory).

#### Organization of argocd-applications

The _argocd-applications/_ subdirectory is organized by application type. Currently, there are three types of applications:
1. Platform components (appearing under _argocd-applications/templates/platform-components/_)
1. Backend components (appearing under _argocd-applications/templates/backend-components/_)
1. Frontend components (appearing under _argocd-applications/templates/frontend-components/_)

#### Adding New Application in the System

In order for a new application to appear in ArgoCD, a template that will render an Application.argoproj.io resource must be added in the appropriate subdirectory under _argocd-applications/templates/_ depending on the application type.

### monitoring

The **monitoring** platform component is a bundle consisting of prometheus, grafana, and alertmanager. This component provides a framework to collect and analyse metrics as well as define responses to certain conditions based on those metrics. The _monitoring/_ subdirectory contains the Helm chart used to install this component.

argocd/argocd-applications vs other subdirectories
--------------------------------------------------

To understand the distinction between these two different directories, it's best to think of what they are used to produce. The Helm templates contained under _argocd/argocd-applications/templates/..._ render **Application.argoproj.io** and **namespace** resources. These are used to get the Application tiles to appear in ArgoCD. The Helm templates contained under the other subdirectories' _templates/_ directory render the actual resources of the component itself (i.e. ConfigMap, Secret, Deployment, Job, etc...)
