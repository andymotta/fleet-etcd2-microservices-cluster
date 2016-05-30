![nginx](../images/nginx.jpg)

### Service Discovery

See: [public-proxy/example-public-service](public-proxy/example-public-service) for a service example.


Dependent service health checks built into the APIs at /disco
* Returns bad HTTP code if API can't talk to connected services.  Discovery sidekick then removes the key, removing the service from the Nginx round-robin.

All services are started on a random docker port, then the discovery sidekick takes care of registering (on deploy) and deregistering (on stop/health check failure) IP:PORT in etcd.
