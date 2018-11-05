import subprocess
from subprocess import Popen, PIPE

def shell_call(cmd):
	return subprocess.check_output(cmd.split())

nodes = ["ceph-node0", "ceph-node1", "ceph-node2"]
cmds = [
	"ceph-deploy new ceph-node0",
	"ceph-deploy install ceph-node0 ceph-node1 ceph-node2",
	"ceph-deploy mon create-initial",
	"ceph-deploy admin ceph-node0 ceph-node1 ceph-node2",
	"ceph-deploy mgr create ceph-node0",
	"echo 'osd_check_max_object_name_len_on_startup = false' >> ceph.conf",
	"ceph-deploy --overwrite-conf config push ceph-node0 ceph-node1 ceph-node2",
	"ceph-deploy osd create --filestore --data /dev/sdb --journal /dev/sdc1 ceph-node0",
	"ceph-deploy osd create --filestore --data /dev/sdb --journal /dev/sdc1 ceph-node1",
	"ceph-deploy osd create --filestore --data /dev/sdb --journal /dev/sdc1 ceph-node2"
]
for i in cmds:
	shell_call(i)