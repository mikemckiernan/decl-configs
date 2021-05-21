# Setting a custom default certificiate

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
