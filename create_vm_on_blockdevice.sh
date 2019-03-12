#!/bin/bash
################################
# Created : 20190121
# Purpose : Create instance on block device
# Usage : ./create_vm_on_blockdevice.sh CirrOS tiny vlan200 os18nova01 user_data_filename instance_name
################################
source ~/openrc

if [ "$1" == "-h" ]; then
  echo "Usage: ./`basename $0` CirrOS tiny vlan200 os18nova01 user_data_filename instance_name"
  exit 0
fi

init()
{
  echo "Initialize variables..."
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

  keypair="burgerkey"

  echo "instance name : $instance_name"
  echo "image_id : $image_id"
  echo "flavor_id : $image_id"
  echo "network_id : $network_id"
  echo "hostname : $host_name"
  echo "availability zone : $az_name"
  echo "user data : $user_data"
  echo "keypair : $keypair"
}

create_vm_on_blockdevice()
{
  echo "VM $instance_name is initialized at $az_name:$host_name"
  echo -e "Image : $image_id;\nFlavor : $flavor_id;\nNetwork : $network_id"
  
  echo "Fire command : nova boot --flavor $flavor_id --nic net-id=$network_id --block-device source=volume,id=$vol_id,dest=volume,size=$randsize,shutdown=preserve,bootindex=0 --user-data $user_data --key-name $keypair --availability-zone $az_name:$host_name $instance_name"
  instance_id=$(nova boot --flavor $flavor_id --nic net-id=$network_id --block-device source=volume,id=$vol_id,dest=volume,size=$randsize,shutdown=preserve,bootindex=0 --user-data $user_data --key-name $keypair --availability-zone $az_name:$host_name $instance_name | grep -w id | grep -v volume | awk '{print $4}')
}

check_vm_creation_status()
{
  vm_creation_status=$(nova show $instance_id | grep -w status | awk '{print $4}')
  echo $vm_creation_status
  while [ $vm_creation_status = BUILD ]
  do
    echo "$instance_id status : $vm_creation_status"
    sleep 5
    vm_creation_status=$(nova show $instance_id | grep -w status | awk '{print $4}')
  done
  echo "$instance_id status : $vm_creation_status"
}

create_volume()
{
  echo "image ID : $image_id"
  randsize=$(python -c "import random; print random.randrange(1,50)*10")
  volname=vol`date +%Y%m%d%H%M%S`$c
  vol_id=$(openstack volume create --image $image_id --size $randsize --bootable --description "created by script" $volname | grep -w id | awk '{print $4}')
  echo $vol_id >> volume_created_`date +%Y%m%d`.txt
  echo "created :" $volname "of size(GB) :" $randsize "id:" $vol_id
}

check_volume_creation_status()
{
  vol_creation_status=$(openstack volume show $vol_id | grep -w "status " | awk '{print $4}')
  while [ $vol_creation_status != available ]
  do
    echo "$vol_id status : $vol_creation_status"
    sleep 5
    vol_creation_status=$(openstack volume show $vol_id | grep -w "status " | awk '{print $4}')
  done
  echo "$vol_id status : $vol_creation_status"
}

init $1 $2 $3 $4 $6 $5
echo
echo "start creating volume..."
create_volume
echo "volume creation status..."
check_volume_creation_status
echo
echo "start creating vm..."
create_vm_on_blockdevice
echo "creation status..."
check_vm_creation_status
