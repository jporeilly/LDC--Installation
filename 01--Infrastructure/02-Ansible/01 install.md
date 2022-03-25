## <font color='red'>Installation of Ansible 2.9.6</font>  

Ansible is an open source IT Configuration Management, Deployment & Orchestration tool. It aims to provide large productivity gains to a wide variety of automation challenges. This tool is very simple to use yet powerful enough to automate complex multi-tier IT application environments. 

In this lab we're going to:
* Install ansible controller

#### If you're new to Ansible you may want to take the course: [LDS3013S](https://learning.lumada.hitachivantara.com/course/introduction-to-ansible-lds3013s) - Introduction to Ansible.

<font color='green'>Ansible has been installed and configured - Reference only.</font>

---

#### <font color='red'>Pre-requisties</font>  
 
Please ensure that the Environment has been configured as outlined in the previous section - 01-Environment:
* installer user added - with sudo & passwordless privileges
* openssh server - check ssh
* pip & pip3

``apply updates:``
```
sudo apt update
sudo apt upgrade -y
sudo reboot
```

---
 

<em>Install Ansible</em> 
This installs Ansible on Ubuntu 18.04.

``install ansible:``
```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```
``verify the installation:``
```
ansible --version
```
Note: the path to ansible.cfg  path to python & python version..  

``browse ansible directory:``
```
cd   /etc/ansible
ls -lrt
```
Note: the directory & configuration files.
* roles - directory for ansible roles
* hosts - inventory file
* ansible.cfg - ansible configuration file

> for further information: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#


``to remove ansible:``
```
sudo apt-get purge --auto-remove ansible 
```

---