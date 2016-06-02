default: packages deploy

deploy: plan terraform
	terraform apply -input=false < plan

plan: templates terraform
	terraform plan -input=false -out plan

templates: master1-cloud-config.yml master2-cloud-config.yml master3-cloud-config.yml public-worker-cloud-config.yml internal-worker-cloud-config.yml

master1-cloud-config.yml: cluster_uuid
	cat templates/master-cloud-config.yml.template | sed -e "s#{{ cluster_uuid }}#`cat cluster_uuid`#" | sed -e "s#{{ etcd_name }}#etcd1#" > master1-cloud-config.yml

master2-cloud-config.yml: cluster_uuid
	cat templates/master-cloud-config.yml.template | sed -e "s#{{ cluster_uuid }}#`cat cluster_uuid`#" | sed -e "s#{{ etcd_name }}#etcd2#" > master2-cloud-config.yml

master3-cloud-config.yml: cluster_uuid
	cat templates/master-cloud-config.yml.template | sed -e "s#{{ cluster_uuid }}#`cat cluster_uuid`#" | sed -e "s#{{ etcd_name }}#etcd3#" > master3-cloud-config.yml

public-worker-cloud-config.yml:
	cat templates/worker-cloud-config.yml.template | sed -e "s#{{ pub_priv }}#etcd=public#"  > public-worker-cloud-config.yml

internal-worker-cloud-config.yml:
	cat templates/worker-cloud-config.yml.template | sed -e "s#{{ pub_priv }}#etcd=internal#" > internal-worker-cloud-config.yml

cluster_uuid:
	uuidgen > cluster_uuid

destroy: terraform
	terraform destroy -input=false

clean:
	rm -f plan
	rm -f discovery_url
	rm -f cluster_uuid
	rm -f master[0-9]-cloud-config.yml
	rm -f *worker-cloud-config.yml
	rm -f deploy_output

clean-all: destroy clean
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup

packages: /usr/local/bin/fleetctl /usr/local/bin/terraform

fleetctl: /usr/local/bin/fleetctl

/usr/local/bin/fleetctl:
	brew install fleetctl

terraform: /usr/local/bin/terraform

/usr/local/bin/terraform:
	brew install terraform

sshuttle: /usr/local/bin/sshuttle

/usr/local/bin/sshuttle:
	brew install sshuttle
