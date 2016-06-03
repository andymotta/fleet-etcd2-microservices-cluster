# Fleet Microservices Cluster
This project started as a way to run containers in AWS without vendor lock-in, but has since been adapted to run in AWS VPC for production.

## Architecture
Fleet's backend is etcd, so we are using a central services architecture for this production deployment:
![etcd](images/central-services.png)

Source: <https://coreos.com/os/docs/latest/cluster-architectures.html#production-cluster-with-central-services>

### What does the template create?
* 3 static etcd masters in private subnets (central services)
* 1 internal worker pool/autoscaling group in a private subnet (workers)
* 1 public worker pool/autoscaling group in a pubilc subnet (workers)
* An internal ELB to access [FleetUI](https://github.com/purpleworks/fleet-ui)
* An internal ELB to access [etcd-browser](https://github.com/henszey/etcd-browser)
* An Ubuntu AMI which provides a [VPN-ish tunnel](http://sshuttle.readthedocs.io/en/stable/how-it-works.html) to access internal resources (If you don't have VPN Gateway)
* A temporary deployment host to deploy units from https://github.com/andymotta/fleet-unit-files
* **Optional** [vpc-in-a-box](https://github.com/andymotta/vpc-in-a-box) creates a new VPC with public and private subnets and a NAT gateway for private net

## Pre-Deployment
1. Download
[Terraform](https://terraform.io/downloads.html) then extract the binaries to some bin directory within your path.

2. **Optional:** Create the Fleet Demo VPC: [vpc-in-a-box](https://github.com/andymotta/vpc-in-a-box)

3. Check **variables.tf** for what you need to change.
  * Required in all cases:
    * yourPubIP = [Your Public IP address](https://www.whatismyip.com)
    * vpc, public_subnets, private_subnets
      * Just copy outputs from vpc-in-a-box
  * Required if you are using an existing VPC:
    * vpc-cidr, region, azs, MasterIPazA, MasterIPazB, MasterIPazC

4. Copy terraform.tfvars.editme to terraform.tfvars and add AWS creds
  * key_name = The name of the key you want to use for your instances
  * key_file  = The local location of the pem you use to access the same instances (Required for file provisioner)

## Deploy the stack
`make | tee deploy_output`

If something goes wrong/red, fix the likely obvious error and run `make` again.  Terraform will start from where it left off.

If all goes well, **check-in the resulting deployment files** to destroy the stack later

## Post-Deployment
If everything was successful, the end of the deployment will output something like this:
```
Outputs:

  etcd_browser = http://internal-etcd-browser-elb-299426784.us-west-2.elb.amazonaws.com
  fleet_ui     = http://internal-FleetUI-elb-1011670857.us-west-2.elb.amazonaws.com
  sshuttle     = sshuttle -r ubuntu@54.201.214.114 0/0 -D
```
If you already have VPN gateway setup with your office and you can access your VPC locally, ignore/poweroff the sshuttle instance.

Otherwise, [install sshuttle](http://sshuttle.readthedocs.io/en/stable/installation.html) locally (if the Makefle didn't install it already).

Now you can run the sshuttle output: `sshuttle -r ubuntu@<IPFromYourOutput> 0/0 -D`
  * Make sure your AWS SSH key is added to your ssh-agent first `ssh-add ~/.ssh/your-cloud-key.pem`

If all goes well you are now able to access
`http://internal-etcd-browser-elb-<whatever>.us-west-2.elb.amazonaws.com` and
`http://internal-FleetUI-elb-<whatever>.us-west-2.elb.amazonaws.com`

...as if you were sitting right in your VPC... reminding you of your datacenter days when you had to wear a winter coat to work in the summer.

## Destroy the stack
* This will clean up all deployment files and leave you with nothing resembling a previous deployment:
`make clean-all`
* This will just destroy the stack:
`terraform destroy`


### Etcd Links:
Etcd was planned carefully with static masters, but here is some great information for running etcd in production:
* Here you will find the fault-tolerance table for retaining registry quorum:  https://coreos.com/etcd/docs/latest/admin_guide.html#fault-tolerance-table
* Check out the turning parameters, especially if running cross-region masters: https://coreos.com/etcd/docs/latest/tuning.html
* Getting the configuration flags right is a must when bootstrapping etcd
* API Docs: https://coreos.com/etcd/docs/latest/api.html
* **Recommended**: use client certificates to secure communication: https://coreos.com/os/docs/latest/customize-etcd-unit.html
  -Right now we're running etcd on private net only, single VPC only

### ToDo:
* Client certificates (above)
* Refactor main to modules
* Need SG for internal services
* Hashicorp vault for fleet journal keys and .dockercfg
* Use Route53 internal hosted zone for microservice endpoint resolution

**One final note...**
The easiest way to get your **.dockercfg** onto every machine in the worker autoscaling group is to use the worker-cloud-config.yml.template.

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
