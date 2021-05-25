# Configuring egress IPs for a project

## Imperative is fine--declarative not so much

The imperative method is perfectly clear and successful:

```bash
oc patch netnamespace openshift-vsphere-infra \
    --type=merge -p \
    '{"egressIPs":["192.168.1.100","192.168.1.101"]}'
```

Retrieve the resource and store as YAML:

```bash
k get netnamespace openshift-vsphere-infra -o yaml > vsphere-netname-egress-ip.yaml
```

Edit the YAML file to change the two IP addresses, remove `creationTimestamp`,
`resourceVersion`, `uid`, and `generation` from the `metadata` field and attempt
to apply it:

```bash
oc apply -f vsphere-netname-egress-ip.yaml -n openshift-vsphere-infra
```

I do not understand why I am unable to apply the manifest.

```text
Error from server (UnsupportedMediaType): error when applying patch:
{"egressIPs":["192.168.2.100","192.168.2.101"],"metadata":{"annotations":{"kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"network.openshift.io/v1\",\"egressIPs\":[\"192.168.2.100\",\"192.168.2.101\"],\"kind\":\"NetNamespace\",\"metadata\":{\"annotations\":{},\"name\":\"openshift-vsphere-infra\"},\"netname\":\"openshift-vsphere-infra\"}\n"}}}
to:
Resource: "network.openshift.io/v1, Resource=netnamespaces", GroupVersionKind: "network.openshift.io/v1, Kind=NetNamespace"
Name: "openshift-vsphere-infra", Namespace: ""
for: "vsphere-netname-egress-ip.yaml": the body of the request was in an unknown format - accepted media types include: application/json-patch+json, application/merge-patch+json, application/apply-patch+yaml
```

## Hostsubnet

An attempt to `oc apply -f worker-1-hostsubnet-egress-cidrs.yaml` results in
essentially the same error as attempting to add an egress IP.
