# MetalLB samples

## Initial configuration

After installing the MetalLB Operator, perform the initial configuration of
MetalLB by applying a manifest like the following:

```yaml
apiVersion: metallb.io/v1beta1
kind: MetalLB
metadata:
  name: metallb
  namespace: metallb-system
```

At this point, the Operator starts the two software components for MetalLB:

- `controller`
- `speaker`

## Address pool configuration

When MetalLB is run without the Operator, the IP addresses that it can assign to
services are identified in a config map named `config` in the `metallb-system`
namespace.

When the MetalLB Operator is available, a custom resource definition,
`AddressPool` is added to the cluster. Instead of managing a config map, add
address pool instances like the following example:

```yaml
apiVersion: metallb.io/v1alpha1
kind: AddressPool
metadata:
  namespace: metallb-system
  name: doc-example
spec:
  protocol: layer2
  addresses:
    - 172.18.255.200-172.18.255.250
---
apiVersion: metallb.io/v1alpha1
kind: AddressPool
metadata:
  namespace: metallb-system
  name: gold
spec:
  protocol: layer2
  addresses:
    - 192.168.10.1/32
    - 192.168.10.5/32
  autoAssign: false
```

## Play time

Apply the deployment manifest from the `agnhost-deployment.yaml` file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-agnhost
spec:
  selector:
    matchLabels:
      run: test-agnhost
  replicas: 2
  template:
    metadata:
      labels:
        run: test-agnhost
    spec:
      containers:
        - args:
            - netexec
          image: k8s.gcr.io/e2e-test-images/agnhost:2.32
          name: agnhost
          ports:
            - containerPort: 8080
              protocol: TCP
      dnsConfig:
        nameservers:
          - 1.1.1.1
        searches:
          - resolv.conf.local
      dnsPolicy: None
```

After applying the manifest for the deployment, apply the manifest for the
service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: test-agnhost
spec:
  selector:
    run: test-agnhost
  ports:
    - port: 80
      targetPort: 8080
      protocol: TCP
  type: LoadBalancer
```

Because the service does not include an annotation that specifies which address
pool to use and does not request a specific IP address, MetalLB selects an
address from the pools that do not explicitly set `autoAssign` to `false`. In
this case, the `doc-example` address pool offers automatic assignment and
MetalLB selects an IP address from that pool.

```bash
k get svc test-agnhost
```

```bash
NAME           TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
test-agnhost   LoadBalancer   172.30.124.152   172.18.255.200   80:30138/TCP   3h26m
```
