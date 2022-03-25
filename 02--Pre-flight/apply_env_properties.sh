#/bin/sh

file="env.properties"

if [ -f "$file" ]
then
  echo "$file found"

  while IFS='=' read -r key value
  do
    eval ${key}=${value}
  done < "$file"

  echo "Installer Node Hostname = " ${installer_node_hostname}
  echo "Installer Node IP       = " ${installer_node_ip}
  echo "Cluster Node Hostname   = " ${cluster_node_hostname}
  echo "Cluster Node IP         = " ${cluster_node_ip}
  echo "Pem File Name           = " ${pem_file_name}
  echo "Ansible User            = " ${ansible_user}
else
  echo "$file not found."
fi

find ./installers/ -type f -exec sed -i -e "s/PLACEHOLDER_INSTALLER_NODE_HOSTNAME/$installer_node_hostname/g" {} \;
find ./installers/ -type f -exec sed -i -e "s/PLACEHOLDER_INSTALLER_NODE_IP/$installer_node_ip/g" {} \;
find ./installers/ -type f -exec sed -i -e "s/PLACEHOLDER_CLUSTER_NODE_HOSTNAME/$cluster_node_hostname/g" {} \;
find ./installers/ -type f -exec sed -i -e "s/PLACEHOLDER_CLUSTER_NODE_IP/$cluster_node_ip/g" {} \;
find ./installers/ -type f -exec sed -i -e "s/PLACEHOLDER_PEM_FILE_NAME/$pem_file_name/g" {} \;
find ./installers/ -type f -exec sed -i -e "s/PLACEHOLDER_ANSIBLE_USER/$ansible_user/g" {} \;
