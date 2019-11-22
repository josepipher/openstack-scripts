#!/bin/bash

id=$(openstack project list | tail -n +4 | head -n -1 | awk '{print $2}')
name=$(openstack project list | tail -n +4 | head -n -1 | awk '{print $4}')
len=$(echo $id | wc -w)
printf "Number of VMs \tProject\n"
printf "============= \t=======\n"
for i in $(seq $len); do printf $(echo $name | awk '{print $var1}' var1=$i)"\t"; openstack server list --project $(echo $id | awk '{print $var2}' var2=$i) | grep -iE 'active|shutoff' | wc -l; done
