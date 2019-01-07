#!/bin/bash
source ~/openrc

networkcount=0
echo "All network IDs (from openstack, filter metadata-proxy) :"
echo "---------------------------------------------------------"
for i in $(openstack network list | sed 1,3d | head -n -1 | awk '{print $2}');
do
echo -e $i $(ip netns exec 'qdhcp-'$i ip a | grep inet | grep tap | awk '{print $2}' | cut -d '/' -f1) $(ps -ef | grep metadata-prox | grep $i | awk '{print $1,$2}') | column -t
networkcount=$(( networkcount+1 ))
done
echo "All networks : " $networkcount
#echo "All networks : " `expr $(openstack network list | wc -l) - 2`

echo

echo "External network IDs (from openstack) :"
echo "---------------------------------------"
extnetworkcount=0
for i in $(openstack network list --external | sed 1,3d | head -n -1 | awk '{print $2}');
do
echo $i
extnetworkcount=$(( extnetworkcount+1 ))
done
echo "External networks : " $extnetworkcount
#echo "External network : " `expr $(openstack network list --external | wc -l) - 2`

echo

echo "Metadata-proxy ID (from process) :"
echo "----------------------------------"
proxycount=0
for i in $(ps -ef | grep -v grep | grep metadata-prox |  awk '{print $10}' | cut -d '/' -f7 | cut -d '.' -f1);
do
echo $i
proxycount=$(( proxycount+1 ))
done
echo "Metadata-proxy count : " $proxycount

echo

echo "External network PIDs (from file) :"
echo "-----------------------------------"
for i in $(ls /var/lib/neutron/external/pids/ | cut -d '.' -f1);
do
echo $i $(cat '/var/lib/neutron/external/pids/'$i'.pid')
done
echo "External PIDs : " `expr $(ls -l /var/lib/neutron/external/pids/ | wc -l) - 1`

