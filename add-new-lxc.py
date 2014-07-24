#!/usr/bin/python
import os, sys, time, yaml

def _status():
    return yaml.safe_load(os.popen('juju status').read())

def containers():
    return _status()['machines']["0"]['containers'].keys()

def container_status(cont):
    return _status()['machines']["0"]['containers'][cont].get('agent-state', 'none')

old_containers = containers()
print >>sys.stderr, "old containers", old_containers

os.system("juju add-machine lxc:0")

new_containers = containers()
print >>sys.stderr, "new containers", new_containers

new_cont, = set(new_containers) - set(old_containers)
print >>sys.stderr, "new container", new_cont

while 1:
    status = container_status(new_cont)
    if status == 'started':
        break
    print >>sys.stderr, new_cont, "status is", status
    time.sleep(5)

print new_cont
