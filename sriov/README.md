# SR-IOV

## Declaratively

Apply the manifest:

```bash
oc apply -f enable-injector.yaml
```

Generates a warning and configures the resource:

```text
Warning: resource sriovoperatorconfigs/default is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by oc apply. oc apply s
hould only be used on resources created declaratively by either oc create --save-config or oc apply. The missing annotation will be patched automatically.
sriovoperatorconfig.sriovnetwork.openshift.io/default configured
```

Check if any harm was done:

```bash
k get sriovoperatorconfig default -n openshift-sriov-network-operator -o jsonpath="{.spec}"
```

```text
{"enableInjector":true,"enableOperatorWebhook":true,"logLevel":2}
```

## Imperatively

First try:

```bash
oc patch -n openshift-sriov-network-operator sriovoperatorconfig default --type=merge --patch-file enable-injector-patch.yaml
```

```text
sriovoperatorconfig.sriovnetwork.openshift.io/default patched (no change)
```

Nothing seems harmed:

```bash
k get sriovoperatorconfig default -n openshift-sriov-network-operator -o jsonpath="{.spec}"
```

```text
{"enableInjector":true,"enableOperatorWebhook":true,"logLevel":2}
```

## Kustomize

View the manifest that `kustomize` generates:

```bash
kustomize build .
```

```text
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovOperatorConfig
metadata:
  name: default
  namespace: openshift-sriov-network-operator
spec:
  enableInjector: true
  enableOperatorWebhook: true
```

## Play time

To control which nodes are selected for the SR-IOV daemon, add a custom label to
a node:

```bash
cat add-node-label.yaml
```

```yaml
apiVersion: v1
kind: Node
metadata:
  labels:
    doc-demo.openshift.io/role: worker
  name: worker-1.ci-ln-9sc6z7k-86010.origin-ci-int-aws.dev.rhcloud.com
```

Apply the label:

```bash
oc apply -f add-node-label.yaml
```

I'm still missing something because I continue to trigger a warning:

```text
Warning: resource nodes/worker-1.ci-ln-9sc6z7k-86010.origin-ci-int-aws.dev.rhcloud.com is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by oc apply. oc apply should only be used on resources created declaratively by either oc create --save-config or oc apply. The missing annotation will be patched automatically.
node/worker-1.ci-ln-9sc6z7k-86010.origin-ci-int-aws.dev.rhcloud.com configured
```

As usual, despite the warning, the change is applied. Verify the change by
viewing the labels:

```bash
k get node worker-1.ci-ln-9sc6z7k-86010.origin-ci-int-aws.dev.rhcloud.com -o jsonpath="{.metadata.labels}" | jq .
```

The `"doc-demo.role": "worker"` label is present:

```json
{
  "beta.kubernetes.io/arch": "amd64",
  "beta.kubernetes.io/os": "linux",
  "doc-demo.role": "worker",
  "kubernetes.io/arch": "amd64",
  "kubernetes.io/hostname": "worker-1.ci-ln-9sc6z7k-86010.origin-ci-int-aws.dev.rhcloud.com",
  "kubernetes.io/os": "linux",
  "node-role.kubernetes.io/worker": "",
  "node.openshift.io/os_id": "rhcos"
}
```

View the manifest that will result from `kustomize`:

```bash
kustomize build .
```

```text
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovOperatorConfig
metadata:
  name: default
  namespace: openshift-sriov-network-operator
spec:
  configDaemonNodeSelector:
    doc-demo.role: worker
  enableInjector: true
  enableOperatorWebhook: true
```

Apply the manifest:

```bash
oc apply -k .
```

```text
Warning: resource sriovoperatorconfigs/default is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by oc apply. oc apply should only be used on resources created declaratively by either oc create --save-config or oc apply. The missing annotation will be patched automatically.
sriovoperatorconfig.sriovnetwork.openshift.io/default configured
```

Verify that the Operator was configured and uses the label to determine which
nodes receive the daemons:

```bash
k get pods -n openshift-sriov-network-operator
```

The short duration for the `sriov-network-config-daemon` pod indicates success:

```text
NAME                                      READY   STATUS    RESTARTS   AGE
network-resources-injector-n6kps          1/1     Running   0          37m
network-resources-injector-qbdfn          1/1     Running   0          37m
network-resources-injector-szbzw          1/1     Running   0          37m
operator-webhook-f6vxb                    1/1     Running   0          37m
operator-webhook-sv2kv                    1/1     Running   0          37m
operator-webhook-szsqc                    1/1     Running   0          37m
sriov-network-config-daemon-phkkk         1/1     Running   0          9s
sriov-network-operator-6cddcc77d4-kcjzm   1/1     Running   0          37m
```

Verify no harm to the configuration and that the `spec.logLevel` field remains
untouched:

```bash
k get -n openshift-sriov-network-operator \
    sriovoperatorconfig default \
    -o jsonpath="{.spec}" | jq .
```

```json
{
  "configDaemonNodeSelector": {
    "doc-demo.role": "worker"
  },
  "enableInjector": true,
  "enableOperatorWebhook": true,
  "logLevel": 2
}
```
