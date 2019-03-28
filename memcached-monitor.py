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

  # return data manipulation
  return { "hit_rate":hit_rate, "evictions":int(data['evictions']), "fill_percent":fill_percent, \
           "cmd_flush":int(data['cmd_flush']), "cmd_get":int(data['cmd_get']), \
           "cmd_set":int(data['cmd_set']), \
           "kbytes_read":int(data['bytes_read'])/1024, "kbytes_written":int(data['bytes_written'])/1024, \
           "uptime":int(data['uptime']), "curr_connections":int(data['curr_connections']), \
           "listen_disabled_num":int(data['listen_disabled_num']), \
           "conn_yields":int(data['conn_yields']) }

def help():
  print "To use this function :" 
  print "python %s IP1 IP2 IP3" % ( sys.argv[0] )

def main(host1,host2,host3):
  mem_stats_host1 = memcached_hitrate(host1)
  mem_stats_host2 = memcached_hitrate(host2)
  mem_stats_host3 = memcached_hitrate(host3)

  x = PrettyTable()
  x.field_names = ["Key", host1, host2, host3]
  x.add_row([ "Hit Rate %",     mem_stats_host1["hit_rate"], mem_stats_host2["hit_rate"], mem_stats_host3["hit_rate"] ])
  x.add_row([ "Evictions",      mem_stats_host1["evictions"], mem_stats_host2["evictions"], mem_stats_host3["evictions"] ])
  x.add_row([ "Fill Percent %", mem_stats_host1["fill_percent"], mem_stats_host2["fill_percent"], mem_stats_host3["fill_percent"] ])
  x.add_row([ "Command Flush",  mem_stats_host1["cmd_flush"], mem_stats_host2["cmd_flush"], mem_stats_host3["cmd_flush"] ])
  x.add_row([ "Command GET",    mem_stats_host1["cmd_get"],mem_stats_host2["cmd_get"],mem_stats_host3["cmd_get"] ])
  x.add_row([ "Command SET",    mem_stats_host1["cmd_set"],mem_stats_host2["cmd_set"],mem_stats_host3["cmd_set"] ])
  x.add_row([ "kBytes Read",    mem_stats_host1["kbytes_read"],mem_stats_host2["kbytes_read"],mem_stats_host3["kbytes_read"] ])
  x.add_row([ "kBytes Written", mem_stats_host1["kbytes_written"],mem_stats_host2["kbytes_written"],mem_stats_host3["kbytes_written"] ])
  x.add_row([ "Curr_connections",   mem_stats_host1["curr_connections"],mem_stats_host2["curr_connections"],mem_stats_host3["curr_connections"] ])
  x.add_row([ "uptime",         mem_stats_host1["uptime"],mem_stats_host2["uptime"],mem_stats_host3["uptime"] ])
  x.add_row([ "listen_disabled_num",mem_stats_host1["listen_disabled_num"],mem_stats_host2["listen_disabled_num"],mem_stats_host3["listen_disabled_num"] ])
  x.add_row([ "Conn_yields",    mem_stats_host1["conn_yields"],mem_stats_host2["conn_yields"],mem_stats_host3["conn_yields"] ])

  print(x)

if __name__ == '__main__':
    try: main(sys.argv[1], sys.argv[2], sys.argv[3])
    except IndexError: help()
