### How to set API keys in etcd

1. Deploy API key to etcd: `etcdctl set /datadog/apikey abcdefghijklmnopqrstuvwxzy`
1. Load the agent unit into fleet: `fleetctl load datadog.service`
1. Start the agent everywhere : `fleetctl start datadog.service`

's/datadog/sysdig', etc.
