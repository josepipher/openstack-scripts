#!/usr/bin/python
##################################
# Objective : Clean up 'Tiger' VMs
#################################
from openstack import connection

def main():
  import sys; sys.path.append('path-to-your-working-directory')
  import datetime
  from connect_openstack import authen, delete_vms
  
  conn = authen('your-openstack-project-id')
  delete_vms_status = delete_vms(conn, 'tiger')
  
  if delete_vms_status:
    print "Updating file ..."
    with open('path-to-your-working-directory/api_log.txt', 'a') as f:
      f.write( delete_vms_status.__str__() + '\n' )
    print "DONE."

if __name__ == "__main__":
  main()
