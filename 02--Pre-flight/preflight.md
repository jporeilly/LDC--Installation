## <font color='red'>Preflight Tasks</font>  

The following playbooks configure the cluster nodes and installs k8s-1.18.10 using kubespray-2.14.

Prerequisites for the Ubuntu 20.04LTS machines:
* A public key generated on your Ansible Controller
* Key copied to hosts
* SSH passwordless access on Nodes with root permissions

The following playbooks are run:  

#### pre-flight_hardware.yml
* Update packages
* Install common packages
* Refresh DNS
* Reboot Nodes

#### extra-vars.yml
* Configure the env.properties with required values
* Run the apply_env_properties.sh
* Check the extra-vars.yml values

#### download_kubespray.yml
* Create the release directory
* Unpacks kubespray-2.18

#### cluster.yml
* installs and configures k8s-1.22.5

#### pre-flight_ldc.yml
* Update packages
* Ensure Map Max count > 262144
* Install Helm - all Nodes
* Prepare kubeconfig
* Install jq
* Install kubectl
* Configure kubectl for 'installer' access
* Install Docker
* Configure a Docker insecure Registry - Ansible Controller
* Copy over certs to 'installer'
* Install OpenEBS storage class
---

<em>Run the playbook - pre-flight_hardware.yml</em>  
This will update, install and configure the various required packages.

``run the playbook - pre-flight_hardware.yml:``
```
cd /etc/ansible/playbooks
ansible-playbook pre-flight_hardware.yml
```
Note the required vars:  
- ansible_ssh_private_key_file: "~/.ssh/id_rsa"  
- ansible_ssh_private_key_file_name: "id_rsa"  
- ansible_user: k8s  
- change_dns: true  
- dns_server: 10.0.0.254  <font color='green'> # SkyTap DNS </font> 
- ansible_python_interpreter: /usr/bin/python  

---

<em>Define the playbook - extra-vars.yml</em>   
Kubespray has a bunch a defualt values that need to be replaced by the required values defined a s placeholders in the env.properties file.

<font color='green'>The extra-vars.yml has been created.</font>

``browse the following files:``
```
sudo cat env.properties
sudo cat apply_env_properties
sudo cat extra-vars.yml 
```
``edit the env.properties file and enter the following values:``
```
installer_node_hostname=installer.skytap.example
installer_node_ip=10.0.0.02
cluster_node_hostname=ha-proxy.skytap.example
cluster_node_ip=10.0.0.1
pem_file_name=id_rsa
ansible_user=k8s
```
``to define the extra-vars.yml, execute:``
```
./apply_env_properties.sh
```
Note: You may have to change the permission: sudo chmod +ax apply_env_properties.sh  

``check extra-vars.yml``

---

<em>Run the playbook - download_kubespray.yml</em>   
Kubernetes clusters can be created using various automation tools. Kubespray is a composition of Ansible playbooks, inventory, provisioning tools, and domain knowledge for generic OS/Kubernetes clusters configuration management tasks. 

Kubespray provides:
* a highly available cluster
* composable attributes
* support for most popular Linux distributions

#### Kubespray Components
* Kubernetes v1.22.5
* Etcd 3.5.0
* Docker 20.10
* Containerd 1.5.8
* CRI-O 1.22
* CNI-plugins v1.0.1
* Calico v3.20.3
* Cilium 1.9.11
* Flannel 0.15.1
* Kube-ovn 1.8.1
* Kube-Router 1.3.2
* Multus 3.8
* Weave 2.8.1
* CoreDNS 1.8.0
* Nodelocaldns 1.21.1
* Helm 3.7.1
* Nginx-ingress 1.0.4
* Cert-manager 1.5.4
* Kubernetes Dashboard v2.4.0

---

<em>Download Kubespray 2.18</em> 

Pre-requistes:
* Firewalls are not managed by kubespray. You'll need to implement appropriate rules as needed. You should disable your firewall in order to avoid any issues during deployment.  
* If kubespray is ran from a non-root user account, correct privilege escalation method should be configured in the target servers and the ansible_become flag or command parameters --become or -b should be specified. 

Kubespray also offers to easily enable popular kubernetes add-ons. You can modify the list of add-ons in ``inventory/mycluster/group_vars/k8s_cluster/addons.yml``.

``run the download_kubespray.yml playbook:``
```
cd /etc/ansible/playbooks
ansible-playbook -i hosts-skytap.yml --extra-vars="@extra-vars.yml" -b -v download_kubespray.yml
```
Note: check that the hosts-skytap.yml & extra-vars.yml have been copied.

There may be an issue with sync of clocks between hardware clock time and system clock.  
* Run the following command on all Cluster Nodes.

``sync clocks:``
```
sudo hwclock --hctosys
```

There is a sample inventory in the inventory folder. You need to copy that and name your whole cluster (e.g. mycluster). The repository has already provided you the inventory builder to update the Ansible inventory file.  

---

<em>Run cluster.yml</em> 

``run the cluster.yml playbook:``
```
cd /installers/kubespray-release-2.14
ansible-playbook -i hosts-skytap.yml --extra-vars "@extra-vars.yml"  -b -v cluster.yml
```
Note: this is going to take about 5-7 mins..

<font color='green'>The following section is for Reference only.</font>

``if you need to reset the k8s deployment:``
```
cd /installers/kubespray-release-2.18
ansible-playbook -i hosts-skytap.yml --extra-vars="@extra-vars.yml" reset.yml -b -v --become-user=root
```
Note: This will still keep some residual config files, IP routing tables, etc

``rest kubernetes cluster using kubeadm:``
```
kubeadm reset -f
```
``remove all the data from all below locations:``
```
sudo rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*
```
``flush all the firewall (iptables) rules (as root):``
```
sudo -i
iptables -F && iptables -X
iptables -t nat -F && iptables -t nat -X
iptables -t raw -F && iptables -t raw -X
iptables -t mangle -F && iptables -t mangle -X
```
``restart the Docker service:``
```
systemctl restart docker
```

---

<em>Create an inventory file</em> 

``copy inventory/sample as inventory/mycluster:``
```
cd /installers/kubespray-release-2.14/inventory
sudo mkdir mycluster
cd ..
sudo chown -R installer mycluster
sudo cp -rfp sample mycluster
declare -a IPS=(10.0.0.101 10.0.0.102 10.0.0.103)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```
``check inventory/mycluster/hosts.yaml``

---

<em>Accessing K8s Cluster from another Workstation</em>   

By default, Kubespray configures kube-master hosts with access to kube-apiserver via port 6443 as http://127.0.0.1:6443. You can connect to this from one of the master nodes.  


``get IP address of Master-Node-01:``
```
# get the  IP address of  master-0
ip=$(grep -m 1  "master-node-01" hosts-skytap.yml | grep -o '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}' | head -n 1)

# ssh to master-node-01
ssh k8s@$ip

# copy /etc/kubernetes/admin.conf file on the local system
ssh k8s@$ip 'sudo cat /etc/kubernetes/admin.conf' > admin.conf
```
``set the Kubeconfig variable:``
```
export KUBECONFIG=admin.conf
```
``replace the Kubernetes API IP address in the admin.conf with one of the control plane node IP addresses:``
```
sudo nano admin.conf
```
or
```
sed -i "s/127.0.0.1/$ip/g" admin.conf
```
``test kubectl:``
```
kubectl get namespace
```

---

<em>Run the playbook - pre-flight_ldc.yml</em>      
This will update, install and configure the various required packages for Data Catalog 7.0.

``run the playbook - pre-flight_ldc.yml:`` 
```
cd /etc/ansible/playbooks
ansible-playbook -i hosts-skytap.yml --extra-vars="@extra-vars.yml" -b -v pre-flight_ldc.yml
```

---

<em>Configure Registry</em>  
Notice that the last few playbooks haven't run.  To complete the playbook tasks:

``restart Docker:``
```
systemctl status docker
systemctl restart docker
```
Note: This is really just a check of the docker service.

``to 'log' the 'installer' user out and in:`` 
```
sudo su - installer 
```
``re-run the playbook - pre-flight_ldc.yml:`` 
```
cd /etc/ansible/playbooks
ansible-playbook -i hosts-skytap.yml --extra-vars="@extra-vars.yml" -b -v pre-flight_ldc.yml -t continue
```
Note:  This will pick up the playbook from the continue tag onwards.

---
