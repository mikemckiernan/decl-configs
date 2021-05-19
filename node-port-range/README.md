# Service node port range

## Declaratively

Apply the manifest:

```bash
oc apply -f cluster.yaml
```

The command results in a warning and indicates that the resource was configured:

```text
Warning: resource networks/cluster is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by oc apply. oc apply should only be used on resources created declaratively by either oc create --save-config or oc apply. The missing annotation will be patched automatically.
network.config.openshift.io/cluster configured
```

## Imperatively

Patch the network configuration:

```bash
oc patch network.config cluster --type merge --patch-file node-port-range-patch.yaml
```

The command does not generate warning. The result indicates that the resource
was configured:

```text
network.config.openshift.io/cluster patched
```
