#!/bin/bash
# This is intended to be run on a compute node, at /root
cd /root
source openrc

# Create images
wget http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img
openstack image create CirrOS --container-format bare --disk-format qcow2 --file cirros-0.3.3-x86_64-disk.img --public
rm -rf cirros-0.3.3-x86_64-disk.img

wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
openstack image create CentOS --container-format bare --disk-format qcow2 --file CentOS-7-x86_64-GenericCloud.qcow2 --public

# Create default flavors.
openstack flavor create --public m1.tiny --ram 512 --disk 1 --vcpus 1
openstack flavor create --public m1.small --ram 2048 --disk 20 --vcpus 1
openstack flavor create --public m1.medium --ram 4096 --disk 40 --vcpus 2
openstack flavor create --public m1.large --ram 8192 --disk 80 --vcpus 4
openstack flavor create --public m1.xlarge --ram 16384 --disk 160 --vcpus 8


