#!/bin/bash
# Prerequisite :
# yum install -y expect

# assume there is only one dhcp agent
dhcpagent=$(ip netns | awk '{print $1}')

###############################
# retrieve instance IP
###############################
instanceName="dell"
instanceList=$(openstack server list --all-projects | grep $instanceName | awk '{print $8}' | cut -d "=" -f 2)

for instanceIP in $instanceList
do
  ###############################
  # execute command on instance
  ###############################
  instancekey="/root/burgerkey"
  instanceUSER="centos"
  
  command="ping -c 50 1.1.1.1 &"
  SSHit="ssh -i $instancekey $instanceUSER@$instanceIP $command"
  
  ACTION=$(expect -c"
  set timeout 3
  
  spawn ip netns exec $dhcpagent $SSHit
  
  expect \"Are you sure you want to continue connecting (yes/no)?\"
  send \"yes\r\"
  
  expect eof
  ")
  
  echo "$ACTION"
  
done
