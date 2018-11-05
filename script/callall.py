# Can't do pipe yet

import sys 
import subprocess
from subprocess import Popen, PIPE

def remote_shell_call(node, cmd):
	ret = None
	try:
		print("\033[0;33m" + "$ ssh " + node + " " + cmd + "\033[0m")
		ret = subprocess.check_output(("ssh " + node + " " +cmd).split(" "))
	except Exception as e:
		print(e)
	return ret

cmds = sys.argv[1:]
nodes = ["node0", "node1", "node2"]
# nodes = ["ceph-node0", "ceph-node1", "ceph-node2"]
for n in nodes:
	ret = remote_shell_call(n, " ".join(cmds))
	print(ret)