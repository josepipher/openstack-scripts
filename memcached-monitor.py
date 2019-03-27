#!/usr/bin/python
###########################################
# Date : 20190327
# Purpose : Check memcache stats, filtered
###########################################
import subprocess, sys
from prettytable import PrettyTable

def memcached_hitrate(host):
  p=subprocess.Popen(['memcached-tool', host, 'stats'], stdout=subprocess.PIPE)
  (output,err) = p.communicate()
  data = {}
  for i in output.split('\n'):
    a = i.split(' ')
    a = filter(None, a)
    if a:
      data[a[0]] = a[1]

  hit_rate = round( float(data['get_hits']) / float(data['cmd_get']) * 100, 2 )
  fill_percent = round( float(data['bytes']) / float(data['limit_maxbytes']) * 100, 2 )

  return [hit_rate, int(data['evictions']), fill_percent, int(data['cmd_flush'])]

def help():
  print "To use this function :" 
  print "python %s IP1 IP2 IP3" % ( sys.argv[0] )

def main(host1,host2,host3):
  mem_stats_host1 = memcached_hitrate(host1)
  mem_stats_host2 = memcached_hitrate(host2)
  mem_stats_host3 = memcached_hitrate(host3)

  x = PrettyTable()
  x.field_names = ["Key", host1, host2, host3]
  x.add_row([ "Hit Rate %",     mem_stats_host1[0], mem_stats_host2[0], mem_stats_host3[0] ])
  x.add_row([ "Evictions",      mem_stats_host1[1], mem_stats_host2[1], mem_stats_host3[1] ])
  x.add_row([ "Fill Percent %", mem_stats_host1[2], mem_stats_host2[2], mem_stats_host3[2] ])
  x.add_row([ "Command Flush",  mem_stats_host1[3], mem_stats_host2[3], mem_stats_host3[3] ])

  print(x)

if __name__ == '__main__':
    try: main(sys.argv[1], sys.argv[2], sys.argv[3])
    except IndexError: help()
