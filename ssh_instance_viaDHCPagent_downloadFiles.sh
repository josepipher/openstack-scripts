#!/bin/bash
##################################################################################################################
# Modified on : 20190307
# Purpose : Do something on a batch of instances, e.g. download file
# Usage : ./ssh_instance_viaDHCPagent_downloadFiles.sh <partial name of ip netns> <partial name of instance name>
# Example : ./ssh_instance_viaDHCPagent_downloadFiles.sh f8e3cd6c-b2d3-4f8b-ae4e-aaac00086e21 pizza
# Note1 : dhcp agent and instance must belong to the same network
# Note2 : instance key has to be provided
##################################################################################################################
source ~/openrc

if [ "$1" == "-h" ]; then
  echo "Usage: ./`basename $0` <ip netns name> <instance name partial>"
  echo "For example : ./`basename $0` f8e3cd6c-b2d3-4f8b-ae4e-aaac00086e21 nova03"
  exit 0
fi

# Prerequisite :
function isinstalled {
  if yum list installed "$@" >/dev/null 2>&1; then
    true
  else
    false
  fi
}

if isinstalled expect; then echo "Prerequisite ready"; else yum install -y expect; echo "Prerequisite installed"; fi

# assume there is only one dhcp agent
# define which dhcp agent
agent=$1
dhcpagent=$(ip netns | awk '{print $1}' | grep $agent)

printf "DHCP Agent : %s\n" $dhcpagent

###############################
# retrieve instance IP
###############################
instanceName=$2
instanceList=$(openstack server list --all-projects | grep $instanceName | awk '{print $8}' | cut -d "=" -f 2)

printf "Instance List : %s\n" $instanceList

# for the first time
firsttime()
{
  for instanceIP in $instanceList
  do
    ###############################
    # execute command on instance
    ###############################
    instancekey="/root/burgerkey"
    instanceUSER="centos"
    
    printf "performing action for : %s\n" $instanceIP
    
    command="sudo yum install -y wget &"
    command2="curl -o 1GB-3.bin https://speed.hetzner.de/1GB.bin &"
    #command="ping -c 50 1.1.1.1 &"
    SSHit="ssh -i $instancekey $instanceUSER@$instanceIP $command2"
    
    ACTION=$(expect -c"
    set timeout 3
    
    spawn ip netns exec $dhcpagent $SSHit
    
    expect \"Are you sure you want to continue connecting (yes/no)?\"
    send \"yes\r\"
    
    expect eof
    ")
    
    echo "$ACTION"
    
  done
}

# other times
othertime()
{
  for instanceIP in $instanceList
  do
    ###############################
    # execute command on instance
    ###############################
    instancekey="/root/burgerkey"
    instanceUSER="centos"
    printf "performing action for : %s\n" $instanceIP
    command="curl -o 10GB.bin https://speed.hetzner.de/10GB.bin &"
    SSHit="ssh -i $instancekey $instanceUSER@$instanceIP $command"
    ip netns exec $dhcpagent $SSHit &
  done
}


#sed -i '/10.2.0/d' /root/.ssh/known_hosts
#sed -i '/10.17.97/d' /root/.ssh/known_hosts
#firsttime
othertime
