## Architecture
Fleet's backend is etcd, so we are using a central services architecture for this production deployment:
![etcd](images/central-services.png)

Source: <https://coreos.com/os/docs/latest/cluster-architectures.html#production-cluster-with-central-services>

## Using Terraform

Download: https://terraform.io/downloads.html
Extract the binaries to some bin directory within your path

* Copy terraform.tfvars.editme to terraform.tfvars and add AWS creds

**Create VPC** or use your own.
* See <https://github.com/andymotta/vpc-in-a-box> to create vpc

Check variables.tf for what you need to change
* If using different master IPs: prepare_templates.sh** will bulk change static IPs (cloud-config workaround)


### Deploy the stack
`make | tee deploy_output`
* Check-in the resulting deployment files to destroy the stack later

### Destroy the stack
* This will clean up all deployment files and leave you with nothing resembling a previous deployment:
`make clean-all`
* This will just destroy the stack:
`terraform destroy`

### Some notes on etcd:
Proper configuration of etcd is extremely important (hence the static masters):
* Here you will find the fault-tolerance table for retaining registry quorum:  https://coreos.com/etcd/docs/latest/admin_guide.html#fault-tolerance-table
* Check out the turning parameters, especially if running cross-region masters: https://coreos.com/etcd/docs/latest/tuning.html
* Getting the configuration flags right is a must when bootstrapping etcd: https://github.com/coreos/etcd/blob/master/Documentation/configuration.md
* If you're like to use the API instead of the CLI (dev-folk), check this out: https://coreos.com/etcd/docs/latest/api.html
* **Optional**: use client certificates to secure communication: https://coreos.com/os/docs/latest/customize-etcd-unit.html (Right now we're running etcd on private net only, single VPC only)

**TODO:**
* Use Route53 internal hosted zone for microservice endpoint resolution
* Add VPC creation as module
* Need separate SG for private subnet backends (inherits SG from public tf, opens etcd ports)

**Final note**...
The easiest way to get your .dockercfg onto every machine in the worker autoscaling group is to use the worker-cloud-config.yml

However, this practice is not recommended by AWS as it's possible to curl UserData locally and could be bad news in the event of an attack.
```
#cloud-config

write_files:
  - path: /home/core/.dockercfg
    owner: core:core
    permissions: 0644
    content: |
      {
        "https://index.docker.io/v1/": {
            "auth":"xxxxxxxxxxxxxxxxxx",
            "email":"you@company.com"
        }
      }
```
