#!/bin/bash
cputotal=0
for i in $(virsh list | sed 1,2d |awk '{print $1}'); do printf "instance# : $i"; temp=$(virsh dumpxml $i | grep nova:vcpus | cut -d'>' -f2 | cut -d'<' -f1); cputotal=$( expr $((cputotal + temp)) ); project=$(virsh dumpxml $i | grep nova:project | cut -d'>' -f2 | cut -d'<' -f1); printf " vcpu : $temp project : $project\n"; done

printf "vcpu provisioned on host : $cputotal\n"
