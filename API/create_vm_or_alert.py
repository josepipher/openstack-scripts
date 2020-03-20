#!/usr/bin/python
##################################
# Objective : Create 'Tiger' VMs
#################################
from openstack import connection
import smtplib
from email.mime.text import MIMEText

def email_alert(vmName):
  msg = MIMEText( \
"""Hi All,

Creation of VM on Openstack failed.

%s

Please take corresponding actions.

Have a good day!

Openstack monitor""" % vmName )

  alert_sender = 'openstack_monitor@your-domain'
  alert_receiver = 'openstack_admin@your-domain'
  msg['Subject'] = 'Create VM failure on Openstack'
  msg['From'] = alert_sender
  msg['To'] = alert_receiver
  s = smtplib.SMTP('your-smtp-server',port=25)
  s.sendmail(alert_sender, alert_receiver, msg.as_string())
  with open('path-to-your-working-directory/api_log.txt', 'a') as f:
    f.write( 'ERROR. Failed to create instance. Email alert sent.\n')

def main():
  import sys; sys.path.append('your-working-directory')
  import datetime
  from connect_vio_vds import authen, create_vm

  try:
    conn = authen('your-openstack-project-id')
    vmName = 'Tiger' + '-' + datetime.datetime.now().strftime("%d %B %Y %I:%M%p")
    # create vm from openstack
    [timeSpent, vm] = create_vm(conn,vmName=vmName,vmNet='your-openstack-network-name-or-id',testFileSource='path-to-your-working-directory/testscript.sh')
    with open('path-to-your-working-directory/api_log.txt', 'a') as f:
      if timeSpent:
        f.write( '%s %s\n' % ( datetime.datetime.now().strftime("%A, %d. %B %Y %I:%M%p"), timeSpent ) )
      else:
        f.write( 'ERROR. No timeSpent.\n' )
  except:
    email_alert(vmName)

if __name__ == "__main__":
  main()

