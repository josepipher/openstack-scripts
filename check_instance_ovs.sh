#!/bin/bash
#-----------------------------------------
# usage : ./check_instance_ovs.sh 'instance id'
# use id from running command : nova list
#-----------------------------------------
source ~/openrc

echo "Instance and DHCP agent information :"
echo "-------------------------------------"

instance_id=$(nova show $1 | grep instance | awk '{print $4}')
instance_tap=$(virsh dumpxml $instance_id | grep tap | cut -d "'" -f2)
instance_tap_tag=$(ovs-vsctl show | grep -C 1 $instance_tap | grep tag | awk '{print $2}')
instance_ip=$(nova show $1 | grep network | awk 'match($0, /([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/) {print substr($0,RSTART,RLENGTH)}')

echo $instance_id $instance_tap 'tag='$instance_tap_tag $instance_ip

for qdhcp in $(ip netns | awk '{print $1}');
do
agent_ip=$(ip netns exec $qdhcp ip a | grep inet | grep tap | awk '{print $2}' | cut -d '/' -f1)
agent_tap=$(ip netns exec $qdhcp ip a | grep inet | grep -iwo tap[a-z,0-9]* | tail -n 1)
agent_tap_tag=$(ovs-vsctl show | grep -C 1 $agent_tap | grep tag | awk '{print $2}')
echo $qdhcp $agent_tap 'tag='$agent_tap_tag $agent_ip
done

echo
echo "VLAN information from ofctl :"
echo "-----------------------------"
ovs-ofctl dump-flows br-int | grep vlan | cut -d ',' -f10
echo

