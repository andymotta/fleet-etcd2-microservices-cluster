## Using Fleet

Build fleet on your workstation: <https://github.com/coreos/fleet> then move the fleetctl binaries somewhere in your path (i.e. /usr/local/bin).

**Optional**: If you are able to run Docker and would like to deploy an application using fleetctl, you might consider this helper:  <https://github.com/vigorsystems/docker-fleetctl-tunnel> This will build fleet and load SSH keys for the job.

Go to the UI: http://PubIPofFleetUIMaster:3000

OR CLI:
Add this to ~/.bashrc or ~/.zshrc:
```
FL=PubIPofFleetUIMaster
eval $(ssh-agent -s)
ssh-add cloud-key.pem
```

### Useful Commands:
```
fleetctl --tunnel $FL ssh login@2
fleetctl --tunnel $FL cat login-discovery@1
fleetctl --tunnel $FL journal --lines 200 service-name@1
```

Launching a unit with fleet is as simple as running `fleetctl start`:
```
$ fleetctl start examples/hello.service
Unit hello.service launched on 113f16a7.../172.17.8.103
```
To launch x amount of instances (example will launch 4):
```
fleetctl --tunnel $FL start service-name@{1..4}.service
```
The `fleetctl start` command waits for the unit to get scheduled and actually start somewhere in the cluster.
`fleetctl list-unit-files` tells you the desired state of your units and where they are currently scheduled:
```
$ fleetctl list-unit-files
UNIT            HASH     DSTATE    STATE     TMACHINE
hello.service   e55c0ae  launched  launched  113f16a7.../172.17.8.103
```
`fleetctl list-units` exposes the systemd state for each unit in your fleet cluster:
```
$ fleetctl list-units
UNIT            MACHINE                    ACTIVE   SUB
hello.service   113f16a7.../172.17.8.103   active   running
```
