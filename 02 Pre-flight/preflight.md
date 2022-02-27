## <font color='red'>Preflight - Hardware</font>  

The following playbooks configure the cluster nodes and installs k8s-1.18.10 using kubespray-2.14.

Prerequisites for the CentOS7 machines:
* A public key generated on your Ansible Controller
* Key copied to hosts
* SSH passwordless access on Nodes with root permissions

The following playbooks are run:  

#### pre-flight_hardware.yml
* Update packages
* Install common packages
* Disable SELinux
* Disable SWAP
* Turn off firewall
* Set hostname
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

Note: if you are getting a mismatch on the urllib3 or chadet:
```
sudo python3 -m pip install --upgrade requests
```

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

``run the download_kubespray.yml playbook:``
```
cd /etc/ansible/playbooks
ansible-playbook -i hosts-skytap.yml --extra-vars="@extra-vars.yml" -b -v download_kubespray.yml
```
Note: check that the hosts-skytap.yml & extra-vars.yml have been copied.

There is a sample inventory in the inventory folder. You need to copy that and name your whole cluster (e.g. mycluster). The repository has already provided you the inventory builder to update the Ansible inventory file.  

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