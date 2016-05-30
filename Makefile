default: packages deploy

deploy: plan terraform
	terraform apply -input=false < plan

plan: templates terraform
	terraform plan -input=false -out plan

templates: ui-master1-cloud-config.yml master2-cloud-config.yml master3-cloud-config.yml priv-worker-cloud-config.yml worker-cloud-config.yml priv-worker-cloud-config.yml

ui-master1-cloud-config.yml: cluster_uuid
	cat templates/ui-master-cloud-config.yml.template | sed -e "s#{{ cluster_uuid }}#`cat cluster_uuid`#" | sed -e "s#{{ etcd_name }}#etcd1#" > ui-master1-cloud-config.yml

master2-cloud-config.yml: cluster_uuid
	cat templates/master-cloud-config.yml.template | sed -e "s#{{ cluster_uuid }}#`cat cluster_uuid`#" | sed -e "s#{{ etcd_name }}#etcd2#" > master2-cloud-config.yml

master3-cloud-config.yml: cluster_uuid
	cat templates/master-cloud-config.yml.template | sed -e "s#{{ cluster_uuid }}#`cat cluster_uuid`#" | sed -e "s#{{ etcd_name }}#etcd3#" > master3-cloud-config.yml

worker-cloud-config.yml:
	cat templates/worker-cloud-config.yml.template | sed -e "s#{{ pub_priv }}#etcd=worker#"  > worker-cloud-config.yml

priv-worker-cloud-config.yml:
	cat templates/worker-cloud-config.yml.template | sed -e "s#{{ pub_priv }}#etcd=internal#" > priv-worker-cloud-config.yml

cluster_uuid:
	uuidgen > cluster_uuid

destroy: terraform
	terraform destroy -input=false

clean:
	rm -f plan
	rm -f discovery_url
	rm -f cluster_uuid
	rm -f master[0-9]-cloud-config.yml
	rm -f ui-master[0-9]-cloud-config.yml
	rm -f worker-cloud-config.yml
	rm -f priv-worker-cloud-config.yml
	rm -f deploy_output
	rm -f outputs.tf

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
