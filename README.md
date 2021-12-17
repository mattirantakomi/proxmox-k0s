# Proxmox-k0s

* Creates Proxmox VMs on Proxmox hosts listed on `inventory` with Ansible
* Installs k0s on Proxmox VMs to be used as worker nodes
* Creates Hetzner Cloud VM with Terraform and installs k0s master on it with Ansible

## Install cluster

Install Terraform:
```
wget -O terraform_1.1.0_linux_amd64.zip https://releases.hashicorp.com/terraform/1.1.0/terraform_1.1.0_linux_amd64.zip
sudo unzip terraform_1.1.0_linux_amd64.zip -d /usr/local/bin/
```

Install Ansible and Community.General module on your own computer:
```
sudo apt-get update
sudo apt-get install -y ansible
ansible-galaxy collection install community.general
```

Install kubectl:
```
sudo wget -O /usr/local/bin/kubectl https://dl.k8s.io/release/v1.23.1/bin/linux/amd64/kubectl
sudo chmod 755 /usr/local/bin/kubectl
```

Create Kubernetes master VM on Hetzner Cloud with Terraform:

```
cd terraform
terraform init
terraform plan
terraform apply
```

Install k0s on master:
```
cd ansible
ansible-playbook master.yml
```

Wait for few minutes and check that master is in `Ready` state:
```
export KUBEKONFIG=~/path-to-this-repo-directory/ansible/files/kubeconfig
kubectl get node -o wide
```

Test connectivity to Proxmox hosts:

`ansible-playbook ping.yml`

Update Proxmox hosts:

`ansible-playbook update.yml`

Download Ubuntu 20.04 LTS cloudimg to Proxmox hosts:

`ansible-playbook ubuntu.yml`

Create Proxmox worker node VMs and install k0s:

`ansible-playbook create_workers.yml`

Wait for few minutes and check every node is in `Ready` state:

`kubectl get node -o wide`

Also check that Calico is running on every node:

`kubectl get pod -n kube-system -o wide -l k8s-app=calico-node`

Install wg-pinger to keep WireGuard tunnels up:

Workaround for https://github.com/k3s-io/k3s/issues/1166

`kubectl apply -f https://raw.githubusercontent.com/mattirantakomi/wg-pinger/master/namespace.yaml`
`kubectl apply -f https://raw.githubusercontent.com/mattirantakomi/wg-pinger/master/daemonset.yaml`

Install ingress-nginx:

`kubectl apply -f yaml/ingress-nginx.yaml`

Check that Nginx responds on http://master.domain.tld/

## Delete cluster

Delete Proxmox worker node VMs:
```
cd ansible
ansible-playbook delete_workers.yml
```

Delete master on Hetzner Cloud
```
cd terraform
terraform destroy
```
