# Declarative configs for networking

This is a temporary repo that Mike created so that he could share some ideas and
receive feedback.

Mike's request:

- Ignore the pull secret and pod.

- Imagine...

  - Customer reads doc that shows the net-attach-def. We'll show one YAML for
    each of the network types.

  - There's common doc about the IPAM config from previous RHOCP 4 releases. I
    think that's still good. URL below.

  - On the HTML page for each network type, the _Next steps_ heading includes a
    link to an existing procedure that shows how to add the network to a pod as
    an annotation.

Everything except the first sub-bullet is existing doc, like the procedure for
configuring a bridge network:
<https://docs.openshift.com/container-platform/4.7/networking/multiple_networks/configuring-bridge.html>.

The purpose of the YAMLs in this repo is to show what I plan to replace our
current `oc edit networks.operator.openshift.io cluster` command with. Instea of
`oc edit...`, the doc can advise creating a YAML file like the sample and then
`oc apply -f ...`.

Regarding the plausibility of these YAMLs, they appear to run and work as-is on
the hardware that is available to me. The ipvlan and macvlan examples require
the sort of cluster that is available to me as "bare metal." On virtualized
hardware, those two reliably do not work and `k describe <pod-name>` includes
the following:

```text
error adding container to network "network-macvlan-static": failed
to create macvlan: device or resource busy
```
