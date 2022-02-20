# ansible-nginx-reverse-proxy-cluster
# Warning
This codebase is pretty opinionated towards my own set up. You could just use [Jeff Geerlings](https://github.com/geerlingguy/ansible-role-nginx) role, or as his github shows, use the [official nginx](https://github.com/nginxinc/ansible-role-nginx) role, install keepalived and manage the nginx config yourself.

# Info
This role will set up a 3 node nginx reverse proxy cluster in ha mode using keepalived.

## To Do
[] I really should be adding tests to my roles
[] Add option to add basic auth to subdomain

# Configuration
## Terraform
Terraform is only used to instantiate the vms, assign them ip addresses and hostnames.

This is very specific to my infrastructure.

An assumption is made that the Hashicorp Vault url and vault tokens are set as environment variables:
```
export VAULT_ADDR=https://<vault_address> && \
export VAULT_TOKEN=<super_secret_short_lived_vault_token>
```

With these vars set, the following make commands are available
```
# Initialise terraform
make terraform-init

# Instantiate vms
make terraform-only

# Instantiate vms, wait 60 secs then run the playbook
make create-vm-and-run-playbook
```

## Ansible
1. Edit the inventory file to contain the ip addresses of your nginx nodes
2. edit the vars in vars/main.yml to reflect your requirements. Node information is stored here. 
   ```NGINX_SHARED_IP``` is a list of the floating ips shared between your hosts

   Set ```GENERATE_CERTS``` to no if you don't have Hashicorp Vault. If set to no, you will need to add in your cert data to relevant files under ./files/
   
   Setting ```GENERATE_CERTS``` to yes uses Hashicorp Vault to generate a new certificate for each site in NGINX_SITES

   ```KEEPALIVED_SCRIPT_USER``` should be set to a user that can start / stop services

   ```NGINX_SITES``` Can contain multiple sites.

   ```NGINX_SITES.DOMAIN``` is the domain name for the site
   ```NGINX_SITES.SUBDOMAINS``` contains all the subdomains that the revers proxy will handle and associated values

   ```NGINX_SITES.SUBDOMAINS.whitelist_ips``` Can be empty. Adding any ips/ranges will deny all traffic from ips not in this list.

   ```NGINX_SITES.SUBDOMAINS.additional_parameters``` Can be empty. Useful for additional parameters. Nextcloud and uptime-kuma are 2 useful examples.

   ```NGINX_SITES.SUBDOMAINS.mode``` Unsure if this needs to be a var, but may be handy.
   
   ```NGINX_SITES.SUBDOMAINS.prioritise_first``` If set to yes, and multiple ips are added to the ip section, then ```backup``` is added to all but the first ip in that list.

   ```NGINX_SITES.LOADBALANCER``` I added enough here to be able to easily set up load balancing for my domain controllers.
3. The ```tasks/prep.yml``` file includes tasks to disable cloud-init and copy a new hosts file over with ips for the nodes buddies. Can be removed if you don't want to get rid of cloud-init.
4. Playbook can be run using the makefile by issuing ```make playbook-only``` for added ~~laziness~~ efficiency.