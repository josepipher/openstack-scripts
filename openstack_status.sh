#!/bin/bash
source ~/openrc
nova-status upgrade check
openstack compute service list
openstack network agent list
openstack volume service list
openstack catalog list
openstack image list
openstack flavor list
