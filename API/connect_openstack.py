#!/usr/bin/python
################################
# Objective : Create VM
# Notes : You may need to add path to import
# import sys; sys.path.append('path-to-your-working-directory')
# from connect_vio_vds import authen, create_vm
################################
from openstack import connection

def authen(p):
  '''Authenticate into Openstack'''
  conn = connection.Connection(
      region_name='nova',
      auth=dict(
          auth_url='https://url-to-api:5000/v3',
          username='your-lovely-username',
          password='your-lovely-password',
          project_id=p,
          user_domain_name='Default'),
      compute_api_version='2',
      identity_interface='public')
  return conn

def create_vm(conn,vmName='Tiger',vmNet='your-lovely-network-name-or-id',testFileSource='path-to-your-working-directory/testscript.sh'):
  '''
  Define properties of VM :
  '''
  import time
  testFile = open(testFileSource)
  startTime = time.time()
  print 'Start :', time.ctime(startTime)
  vm = conn.create_server(name=vmName,flavor='m1.medium',image='CentOS',boot_from_volume=True,terminate_volume=True,volume_size=100,network=vmNet,userdata=testFile)
  testFile.close()
  
  create_state = conn.get_server(vm['id']).vm_state
  
  while create_state != 'active':
    print(time.ctime(time.time()),create_state)
    if create_state == 'error':
      print(time.ctime(time.time()),create_state)
      break
    time.sleep(10)
    create_state = conn.get_server(vm['id']).vm_state
  
  endTime = time.time()
  print 'End :', time.ctime(endTime)
  print 'Nova UUID :', vm['id']
  print 'Status :', create_state
  timeSpent = endTime - startTime
  print 'Time spent (s) : %.2f' % (timeSpent)
  
  return [ timeSpent, conn.get_server(vm['id']) ]

def delete_vms(conn,vmName):
  vms = conn.list_servers()
  delete_vms_status = []
  for vm in vms:
    if vmName.lower() in vm['name'].lower():
      tmp = conn.delete_server( vm['id'] )
      delete_vms_status.append( {"id":vm['id'], "name":vm['name'], "deleted":tmp} )
  return delete_vms_status 

def main():
  print "Hello friend !"

if __name__ == "__main__":
  main()
