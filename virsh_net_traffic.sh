#!/bin/bash
#################################################
# Purpose : List virsh instance network traffic
# Modified on : 20181231
# Modified by : sanjose
#################################################
re='^[0-9]+$'

printf "ID Name Tap1 Rx1(MB) Tx1(MB) Tap2 Rx2(MB) Tx2(MB)\n"
echo -e "-------------------------------------------------"

for i in $(virsh list | sed 1,2d |awk '{print $1}'); do printf "$i $(virsh dumpxml $i | grep nova:name | cut -d'>' -f2 | cut -d'<' -f1)\t" ; for j in $(virsh dumpxml $i | grep tap | cut -d"'" -f2 ); do printf "$j\t" ; for k in $(virsh domifstat $i $j | grep bytes | awk '{print $2,$3}'); do if [[ $k =~ $re ]] ; then printf "`expr $k / 1024 / 1024`\t" ; fi ; done ; done ; echo -e "\n" ; done | column -t

