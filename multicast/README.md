# Enable multicast by setting an annotation

I receive an error when I try to apply the manifest:

```bash
oc apply -f enable-multicast.yaml
```

```text
Error from server (UnsupportedMediaType): error when applying patch:
{"metadata":{"annotations":{"kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"network.openshift.io/v1\",\"kind\":\"NetNamespace\",\"metadata\":{\"annotations\":{\"netnamespace.network.openshift.io/multicast-enabled\":\"true\"},\"name\":\"mmckiern\"}}\n","netnamespace.network.openshift.io/multicast-enabled":"true"}}}
to:
Resource: "network.openshift.io/v1, Resource=netnamespaces", GroupVersionKind: "network.openshift.io/v1, Kind=NetNamespace"
Name: "mmckiern", Namespace: ""
for: "enable-multicast.yaml": the body of the request was in an unknown format - accepted media types include: application/json-patch+json, application/merge-patch+json, application/apply-patch+yaml
```
