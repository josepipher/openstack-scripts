#!/bin/bash
################################################
# ./vol_create.sh "no of volumes"
# e.g. ./vol_create 10
################################################
source ~/openrc

for (( c=1; c<=$1; c++ ))
do
  randsize=$(python -c "import random; print random.randrange(1,50)*10")
  volname=vol`date +%Y%m%d%H%M%S`$c
  id=$(openstack volume create --size $randsize --description "created by script" $volname | grep id | awk 'FNR == 2 {print}' | awk '{print $4}')
  echo $id >> volume_created_`date +%Y%m%d`.txt
  echo "created :" $volname "of size(GB) :" $randsize "id:" $id
done
