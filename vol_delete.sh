#!/bin/bash
################################################
# ./vol_delete.sh "filename"
# e.g. ./vol_delete volume_createdxxxxxxx.txt
################################################
source ~/openrc

filename="$1"
while read -r line; do
  id="$line"
  echo "Vol ID : $id deleting"
  openstack volume delete $id
done < "$filename"

