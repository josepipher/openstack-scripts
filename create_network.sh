#!/bin/bash
############################################
# Objective : Create networks based on VLAN
# Date : 20190212
############################################
network_type="vlan"
VLANstart=2000
VLANend=2011
subnet_mask=24
NumIPs=12
Num=$(($NumIPs+8))

source ~/openrc

create_network(){
for (( VLAN=$VLANstart; VLAN<=$VLANend; VLAN++ ))
do
  a=${VLAN:0:2}
  b=${VLAN:2:2}

  if [ ${a:0:1} -eq 0 ]
  then
    a=${a:1:1}
  fi

  if [ ${b:0:1} -eq 0 ]
  then
    b=${b:1:1}
  fi

  network="10.$a.$b.0"
  network_gw="10.$a.$b.1"
  IPstart="10.$a.$b.2"
  IPend="10.$a.$b.""$Num"
  network_name="FMGcloud_network_10.$a.$b.2"
  subnet_name="FMG_subnet_10.$a.$b.2"

#  printf "neutron net-create $network_name --provider:segmentation_id $VLAN --router:external True --provider:network_type $network_type --provider:physical_network physnet1 --shared\n"
#  neutron net-create $network_name --provider:segmentation_id $VLAN --router:external True --provider:network_type $network_type --provider:physical_network physnet1 --shared
#  printf "neutron subnet-create --gateway $network_gw --allocation-pool start=$IPstart,end=$IPend --dns-nameserver 1.1.1.1 --dns-nameserver 8.8.8.8 --dns-nameserver 208.67.222.222 --enable-dhcp --name $subnet_name $network_name $network/$subnet_mask\n"
  neutron subnet-create --gateway $network_gw --allocation-pool start=$IPstart,end=$IPend --dns-nameserver 1.1.1.1 --dns-nameserver 8.8.8.8 --dns-nameserver 208.67.222.222 --enable-dhcp --name $subnet_name $network_name $network/$subnet_mask

done
}

create_network
openstack network list
openstack subnet list
