#!/bin/bash
source ~/openrc

for vol in $(openstack volume list --all-projects | grep image | awk '{print $2}'); do echo "volume id :$vol"; openstack image show $(openstack volume show $vol | grep properties | cut -d"'" -f2) | grep name; done
