#!/bin/bash
################################
# Created : 20181221
# Purpose : Create instance at specific host
# Usage : ./create_vm_on_specific_host.sh CirrOS tiny vlan200 os18nova01 instance_name
################################
source ~/openrc

create_vm()
{
  instance_name=${5:-scriptVM`date +\%Y\%m\%d\%H\%M`}
  
  image_name=$1
  image_id=$(openstack image list | grep -i ${image_name:-CirrOS} | awk '{print $2}')
  
  flavor_name=$2
  flavor_id=$(openstack flavor list | grep -i ${flavor_name:-tiny} | awk '{print $2}')
  
  network_name=$3
  network_id=$(openstack network list | grep -i ${network_name:-vlan200} | awk '{print $2}')
  
  host_name=$(openstack host list | grep -i ${4:-os18nova03} | awk '{print $2}')
  
  az_name=$(openstack host list | awk -v var=$host_name '$0~var {print $6}')
  
  echo "VM $instance_name is initialized at $az_name:$host_name"
  echo -e "Image : $image_id;\nFlavor : $flavor_id;\nNetwork : $network_id"
  
  echo "Fire command : openstack server create --image $image_id --flavor $flavor_id --nic net-id=$network_id --availability-zone $az_name:$host_name $instance_name"
  instance_id=$(openstack server create --image $image_id --flavor $flavor_id --nic net-id=$network_id --availability-zone $az_name:$host_name $instance_name | grep -w id | grep -v volume | awk '{print $4}')
}

check_vm_creation_status()
{
  creation_status=$(nova show $instance_id | grep -w status | awk '{print $4}')
  while [ $creation_status = BUILD ]
  do
    echo "$instance_id status : $creation_status"
    sleep 5
    creation_status=$(nova show $instance_id | grep -w status | awk '{print $4}')
  done
  echo "$instance_id status : $creation_status"
}

echo "start creating vm..."
create_vm $1 $2 $3 $4 $5
echo "creation status..."
check_vm_creation_status
