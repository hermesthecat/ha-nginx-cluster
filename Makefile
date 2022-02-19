.PHONY: terraform-init
.PHONY: playbook-only
.PHONY: create-vm-and-run-playbook
.PHONY: terraform-only
.PHONY: destroy

terraform-init:
	cd terraform/ && \
	terraform init

terraform-only:
	cd terraform/ && \
	terraform plan -out=deployvm -var "vault_token=$(VAULT_TOKEN)" && \
	terraform apply "deployvm" && \
	cd .. \

playbook-only:
	ansible-playbook -i inventory playbook.yml

create-vm-and-run-playbook:
	cd terraform/ && \
	terraform plan -out=deployvm -var "vault_token=$(VAULT_TOKEN)" && \
	terraform apply "deployvm" && \
	cd .. && \
	echo "Hacky 180s wait for vms to be ready…" && \
	sleep 180 && \
	ansible-playbook -i inventory playbook.yml

destroy:
	cd terraform/ && \
	terraform destroy -var "vault_token=$(VAULT_TOKEN)" && \
	cd ..