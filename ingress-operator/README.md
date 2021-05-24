# Setting a custom default certificate

## Declaratively

```bash
oc apply set-last-applied --create-annotation -f custom-default-cert.yaml
```

> That command deceptively does not configure the resource.

```bash
oc get -n openshift-ingress-operator ingresscontroller default -o jsonpath="{.spec}" | jq .
```

The field `defaultCertificate` is not present:

```json
{
  "httpErrorCodePages": {
    "name": ""
  },
  "replicas": 2,
  "tuningOptions": {},
  "unsupportedConfigOverrides": null
}
```

Apply the same manifest a second time, but without the `set-last-applied`
argument updates the resource. In this case, because the annotation was
previously added, the `apply` command does not produce the warning not to update
resources that were created with `create`.

```bash
oc apply -f custom-default-cert.yaml
```

```text
ingresscontroller.operator.openshift.io/default configured
```

Verify that the resource was updated:

```bash
oc get -n openshift-ingress-operator ingresscontroller default -o jsonpath="{.spec}" | jq .
```

This time, the `defaultCertificate` field is present:

```json
{
  "defaultCertificate": {
    "name": "custom-certs-default"
  },
  "httpErrorCodePages": {
    "name": ""
  },
  "replicas": 2,
  "tuningOptions": {},
  "unsupportedConfigOverrides": null
}
```

## Scaling an Ingress Controller

Because the resource was modified in the previous steps, the `oc apply` command
does not produce a warning.

```bash
oc apply -f set-replias.yaml
```

```text
ingresscontroller.operator.openshift.io/default configured
```

## Configuring the route admission controller

The following `oc apply` generates the common warning about modifying a resource
that does not have the last-applied-configuration annotation.

```bash
k get -n openshift-ingress-operator ingresscontroller default -o yaml > /tmp/x

oc apply -f set-routeaddmission.yaml

k get -n openshift-ingress-operator ingresscontroller default -o yaml > /tmp/y

diff /tmp/x /tmp/y
```

FIXME: The change to the `availableReplicas` field is unexpected.

```text
3a4,6
>   annotations:
>     kubectl.kubernetes.io/last-applied-configuration: |
>       {"apiVersion":"operator.openshift.io/v1","kind":"IngressController","metadata":{"annotations":{},"name":"default","namespace":"openshift-ingress-operator"},"spec":{"routeAdmission":{"namespaceOwnership":"InterNamespaceAllowed"}}}
7c10
<   generation: 1
---
>   generation: 2
10c13
<   resourceVersion: "25933"
---
>   resourceVersion: "68864"
15a19,20
>   routeAdmission:
>     namespaceOwnership: InterNamespaceAllowed
19c24
<   availableReplicas: 2
---
>   availableReplicas: 1
38,41c43,46
<   - lastTransitionTime: "2021-05-24T11:13:35Z"
<     message: All replicas are available
<     reason: DeploymentReplicasAvailable
<     status: "True"
---
>   - lastTransitionTime: "2021-05-24T13:11:20Z"
>     message: 1/2 of replicas are available
>     reason: DeploymentReplicasNotAvailable
>     status: "False"
70c75
<   observedGeneration: 1
---
>   observedGeneration: 2
```
