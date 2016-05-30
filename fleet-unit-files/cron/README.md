### Fleet Timer Units for Cron-like Tasks Across a Cluster

```
➜  ~  fleetctl --tunnel $OV load dockermi*
➜  ~  fleetctl --tunnel $OV start dockermi.timer
```
This will cleanup untagged Docker images on every Docker worker
