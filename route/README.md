# Configure route timeouts

A declarative update is requested to
<https://deploy-preview-32089--osdocs.netlify.app/openshift-enterprise/latest/networking/routes/route-configuration.html#nw-configuring-route-timeouts_route-configuration>.

## Declaratively

```bash
oc apply -n openshift-monitoring -f route-timeout.yaml
```

The previous command produces the typical warning, but succeeds in configuring
the resource.

```text
Warning: resource routes/grafana is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by oc apply. oc apply should only be
used on resources created declaratively by either oc create --save-config or oc apply. The missing annotation will be patched automatically.
route.route.openshift.io/grafana configured
```

Verify that the change is present:

```bash
oc get -n openshift-monitoring route grafana -o jsonpath="{.metadata.annotations}" | jq .
```

```json
{
  "haproxy.router.openshift.io/timeout": "2s",
  "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"route.openshift.io/v1\",\"kind\":\"Route\",\"metadata\":{\"annotations\":{\"haproxy.router.openshift.io/timeout\":\"2s\"},\"name\":\"grafana\",\"namespace\":\"openshift-monitoring\"}}\n",
  "openshift.io/host.generated": "true"
}
```

Change the value in the YAML file to `5s` and apply again:

```bash
oc apply -n openshift-monitoring -f route-timeout.yaml
```

```text
route.route.openshift.io/grafana configured
```

Verify the change is present:

```bash
oc get -n openshift-monitoring route grafana -o jsonpath="{.metadata.annotations}" | jq .
```

```json
{
  "haproxy.router.openshift.io/timeout": "5s",
  "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"route.openshift.io/v1\",\"kind\":\"Route\",\"metadata\":{\"annotations\":{\"haproxy.router.openshift.io/timeout\":\"5s\"},\"name\":\"grafana\",\"namespace\":\"openshift-monitoring\"}}\n",
  "openshift.io/host.generated": "true"
}
```

## Proposed solution

I believe the following change to the AsciiDoc file is considered a possibility.

```text
[TIP]
====
You can alternatively apply the following YAML to add the annotation:

[source,terminal]
----
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    haproxy.router.openshift.io/timeout: 5s
  name: <route_name>
----
====
```

The qualifications with that strategy:

- Because an existing resource is updated, if the customer interprets the TIP to
  suggest using `oc apply`, -then- the customer can experience the same warning
  that a preceding example shows.

- Similarly, because this is an update to a resource, I believe we face the same
  concern over "unreliability."
