# Modify the CNO with the additional network

After failing to trigger a pod stop and start after updating the net-attach-def,
this directory shows an effort to modify the CNO by adding the
`.spec.additionalNetworks` field to the Operator. This aligns more closely with
the documentation and the existing process.

It doesn't work.

1. Update `patches/add-network-bridge-static.yaml` to specify the network
   attachment definition.

1. In the `cno` directory, generate the manifests and apply them:

   ```bash
   kustomize build . | k apply -n mmckiern -f -
   ```

   Expected output

   ```text
   secret/bot-pull-secret created
   deployment.apps/bridge-static-deployment created
   network.operator.openshift.io/cluster configured
   ```

1. View the logs from the sample pod:

   ```bash
   k logs -n mmckiern deployment/bridge-static-deployment
   ```

   Keep track of the IP address that is assigned to the `net1` interface. Change
   the IP address in the `patches/add-network-bridge-static.yaml` file and then
   generate and apply the manifests again. The issue is that the net-attach-def
   changes (I think...), but the pod does not restart and does not receive the
   new IP address.

## Rando aside

The namespace is not added to the `network-bridge-static` additional network. I
guess the `network.operator` object belongs to the default namespace and the
additional network is a _value_ in the kustomization rather than a first-class
object.

```bash
kustomize build . | k delete -n mmckiern -f -
```

Output

```text
secret "bot-pull-secret" deleted
deployment.apps "bridge-static-deployment" deleted
warning: deleting cluster-scoped resources, not scoped to the provided namespace
network.operator.openshift.io "cluster" deleted
```

This isn't a bug, it's a "Huh. Oh. Ok." The alternatives are as follows:

- Add the namespace to the additional network specification in the patch. Insert
  a line between 5 and 6 with `namespace: mmckiern`.

- Use a net-attach-def object as shown in the `network` directory. It sets the
  namespace correctly, but is equally ineffective at triggering a pod restart.

- If you are reading carefully and wondering if the last line indicated trouble,
  it did.
