# Fiddling

Run the following command to install the ArgoCD operator:

```bash
oc apply -k /path/to/decl-configs/argocd/
```

After the operator is installed, add an instance of ArgoCD:

```bash
oc apply -f /path/to/decl-configs/argocd/argocd-argocd.yaml
```

> Why the clever file name?  I'm kicking around the idea that files
> should be named according to the k8s kind and the name of the
> k8s object.  In the preceding case, the object is of kind ArgoCD
> and the instance is named argocd.

Display the route to get the URL for the ArgoCD UI:

```bash
k get route -n argocd
```

Get the URL from the `HOST/PORT` column and log in with the OpenShift
credentials.

Remember to also follow the steps like `argocd login --sso ...` and
`argocd cluster add`.

