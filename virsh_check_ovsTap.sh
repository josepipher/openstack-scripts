#!/bin/bash
# Purpose : Check if tapxxxxx is present in ovs on this host
# Date : 2019-03-15
for i in $(virsh list --all | grep instance | awk '{print $2}');do for j in $(virsh dumpxml $i | grep tap | cut -d"'" -f2); do printf "Instances present :"; echo $i; ovs-vsctl show | grep $j | grep Port; done; done
