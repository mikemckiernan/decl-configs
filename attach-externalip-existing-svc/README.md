# Attach an external IP to an existing service

## Declaratively

Apply the manifest:

```bash
oc apply --record=true -n openshift-operator-lifecycle-manager -f packageserver-svc.yaml
```

The `--record=true` argument does not suppress the warning message:

```text
Warning: resource services/packageserver-service is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by oc apply. oc apply should only be used on resources created declaratively by either oc create --save-config or oc apply. The missing annotation will be patched automatically.
service/packageserver-service configured
```

For amusement, check the update:

```bash
oc get svc -n openshift-operator-lifecycle-manager  packageserver-service -o jsonpath="{.spec.externalIPs}"
```

```text
["192.168.2.33","192.168.2.34"]
```

## Double-plus fun

The following `oc apply` triggers the warning that is common.

```bash
k get svc -n openshift-operator-lifecycle-manager packageserver-service -o yaml > /tmp/x

oc apply -n openshift-operator-lifecycle-manager -f packageserver-svc.yaml

k get svc -n openshift-operator-lifecycle-manager packageserver-service -o yaml > /tmp/y

diff /tmp/x /tmp/y
```

The difference meets expectations:

```text
3a4,6
>   annotations:
>     kubectl.kubernetes.io/last-applied-configuration: |
>       {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"packageserver-service","namespace":"openshift-operator-lifecycle-manager"},"spec":{"externalIPs":["192.168.2.33","192.168.2.34"]}}
14c17
<   resourceVersion: "7758"
---
>   resourceVersion: "56647"
19a23,25
>   externalIPs:
>   - 192.168.2.33
>   - 192.168.2.34
```

## Imperatively

Patch the service:

```bash
oc patch svc -n openshift-operator-lifecycle-manager packageserver-service --type merge --patch-file packageserver-svc-patch.yaml
```

The patch does not result in a warning. The resource is configured:

```text
service/packageserver-service patched
```

The existing IP addresses in the array are clobbered:

```bash
oc get svc -n openshift-operator-lifecycle-manager  packageserver-service -o jsonpath="{.spec.externalIPs}"
```

```text
["192.168.22.33","192.168.22.34"]
```
