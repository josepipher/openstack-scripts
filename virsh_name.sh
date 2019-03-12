#!/bin/bash
for i in $(virsh list | sed 1,2d |awk '{print $1}'); do printf $i; virsh dumpxml $i | grep nova:name ; virsh dumpxml $i | grep tap; virsh dumpxml $i | grep nova:name ; virsh dumpxml $i | grep 'dev/disk'; done
