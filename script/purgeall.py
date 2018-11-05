import subprocess
from subprocess import Popen, PIPE

PURGEPATH="~/purgeme.py"

def shell_call(cmd):
	ret = None
	try:
		print("$ " + cmd)
		ret = subprocess.check_output(cmd.split())
	except Exception as e:
		print(e)
	return ret 


# ceph-deploy purge ceph-node0 ceph-node1 ceph-node2
# ceph-deploy forgetkeys
# rm ceph.*

ceph_purge_cmd = [
	"ceph-deploy purge ceph-node0 ceph-node1 ceph-node2",
	"ceph-deploy forgetkeys",
	"rm ceph.*"
]
for cmd in ceph_purge_cmd:
	shell_call("sudo " + cmd)

nodes=["ceph-node0", "ceph-node1", "ceph-node2"]
for i in nodes:
	shell_call("scp " + PURGEPATH + " " + i + ":~")
	shell_call("ssh "+ i +" sudo ./purgeme.py ")