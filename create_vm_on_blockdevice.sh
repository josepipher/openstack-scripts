#!/bin/bash
################################
# Created : 20190121
# Created by : sanjose
# Purpose : Create instance on block device
# Usage : ./create_vm_on_blockdevice.sh CirrOS tiny vlan200 os18nova01 user_data_filename instance_name
################################
source ~/openrc

if [ "$1" == "-h" ]; then
  echo "Usage: ./`basename $0` CirrOS tiny vlan200 os18nova01 user_data_filename instance_name"
  exit 0
fi

create_vm_on_blockdevice()
{
  instance_name=${5:-blockVM`date +\%Y\%m\%d\%H\%M`}
  
  image_name=$1
  image_id=$(openstack image list | grep -i ${image_name:-CirrOS} | awk '{print $2}')
  
  flavor_name=$2
  flavor_id=$(openstack flavor list | grep -i ${flavor_name:-tiny} | awk '{print $2}')
  
  network_name=$3
  network_id=$(openstack network list | grep -i ${network_name:-vlan200} | awk '{print $2}')
  
  host_name=$(openstack host list | grep -i ${4:-os18nova03} | awk '{print $2}')
  
  az_name=$(openstack host list | awk -v var=$host_name '$0~var {print $6}')
  
  user_data=${6:-testscript.sh}
  
  echo "VM $instance_name is initialized at $az_name:$host_name"
  echo -e "Image : $image_id;\nFlavor : $flavor_id;\nNetwork : $network_id"
  
  echo "Fire command : nova boot --image $image_id --flavor $flavor_id --nic net-id=$network_id --block-device source=volume,id=$vol_id,dest=volume,shutdown=preserve --user-data $user_data --availability-zone $az_name:$host_name $instance_name"
  instance_id=$(nova boot --image $image_id --flavor $flavor_id --nic net-id=$network_id --block-device source=volume,id=$vol_id,dest=volume,shutdown=preserve --user-data $user_data --availability-zone $az_name:$host_name $instance_name | grep -w id | grep -v volume | awk '{print $4}')
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

create_volume()
{
  randsize=$(python -c "import random; print random.randrange(1,50)*10")
  volname=vol`date +%Y%m%d%H%M%S`$c
  vol_id=$(openstack volume create --size $randsize --description "created by script" $volname | grep -w id | awk '{print $4}')
  echo $vol_id >> volume_created_`date +%Y%m%d`.txt
  echo "created :" $volname "of size(GB) :" $randsize "id:" $vol_id
}

echo "start creating volume..."
create_volume
echo "start creating vm..."
create_vm_on_blockdevice $1 $2 $3 $4 $6 $5
echo "creation status..."
check_vm_creation_status
