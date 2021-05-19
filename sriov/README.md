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
