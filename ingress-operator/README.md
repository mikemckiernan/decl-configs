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

## Enabling HTTP2 -- annotations

FIXME: Applying a manifest that `metadata.annotations` for the Ingress
Controller appears to remove the `spec` by setting it to `null`.

The following listing is the output from `diff`. Notice that `spec` is present
in the before (`<`), and not in the after.

```text
4a5
>     ingress.operator.openshift.io/default-enable-http2: "true"
6c7
<       {"apiVersion":"operator.openshift.io/v1","kind":"IngressController","metadata":{"annotations":{},"name":"default","namespace":"openshift-ingress-operator"},"spec":{"routeAdmission":{"namespaceOwnership":"InterNamespaceAllowed"}}}
---
>       {"apiVersion":"operator.openshift.io/v1","kind":"IngressController","metadata":{"annotations":{"ingress.operator.openshift.io/default-enable-http2":"true"},"name":"default","namespace":"openshift-ingress-operator"}}
10c11
<   generation: 2
---
>   generation: 3
13c14
<   resourceVersion: "69362"
---
>   resourceVersion: "79110"
15,22d15
< spec:
<   httpErrorCodePages:
<     name: ""
<   replicas: 2
<   routeAdmission:
<     namespaceOwnership: InterNamespaceAllowed
<   tuningOptions: {}
<   unsupportedConfigOverrides: null
24c17
<   availableReplicas: 2
---
>   availableReplicas: 1
43,46c36,39
<   - lastTransitionTime: "2021-05-24T13:12:47Z"
<     message: All replicas are available
<     reason: DeploymentReplicasAvailable
<     status: "True"
---
>   - lastTransitionTime: "2021-05-24T13:40:23Z"
>     message: 1/2 of replicas are available
>     reason: DeploymentReplicasNotAvailable
>     status: "False"
75c68
<   observedGeneration: 2
---
>   observedGeneration: 3
```

I am speculating that there is something unique to the preceding update. Using
`oc apply` with the following manifest does not delete the `spec` field from a
service:

```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    doc-demo: "true"
  name: metrics
  namespace: openshift-service-ca-operator
```

Check the update:

```bash
k get svc -n openshift-service-ca-operator metrics -o yaml
```

```text
apiVersion: v1
kind: Service
metadata:
  annotations:
    doc-demo: "true"
    include.release.openshift.io/ibm-cloud-managed: "true"
    include.release.openshift.io/self-managed-high-availability: "true"
    include.release.openshift.io/single-node-developer: "true"
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{"doc-demo":"true"},"name":"metrics","namespace":"openshift-service-ca-operator"}}
    service.alpha.openshift.io/serving-cert-signed-by: openshift-service-serving-signer@1621854062
    service.beta.openshift.io/serving-cert-secret-name: serving-cert
    service.beta.openshift.io/serving-cert-signed-by: openshift-service-serving-signer@1621854062
  creationTimestamp: "2021-05-24T10:50:12Z"
  labels:
    app: service-ca-operator
  name: metrics
  namespace: openshift-service-ca-operator
  resourceVersion: "85927"
  uid: b9009ac3-6277-4e16-94f5-5ab60e75fd03
spec:
  clusterIP: 172.30.33.10
  clusterIPs:
  - 172.30.33.10
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ...
```
