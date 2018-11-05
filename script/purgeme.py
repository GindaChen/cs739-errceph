# sudo umount /dev/ceph-*
# sudo lvdisplay -C -o lv_path
# sudo fdisk -l
# sudo vgscan


import subprocess
from subprocess import Popen, PIPE

def shell_call(cmd):
	ret = None
	try:
		print("\033[0;33m" + "$ " + cmd + "\033[0m")
		ret = subprocess.check_output(cmd.split())
	except Exception as e:
		print(e)
	return ret

# 1 sudo umount ${LV_PATH}
lv_path = shell_call("sudo lvdisplay -C -o lv_path")
a = lv_path.find("\n") + 3
b = lv_path[a:].find("\n") + a
lv_path = lv_path[a:b]
shell_call("sudo umount " + lv_path)


# 2 sudo lvremove -y ${$(sudo fdisk -l something)}
fdisk = shell_call('sudo fdisk -l')
a = fdisk.find("/dev/mapper")
b = fdisk[a:].find(":") + a
fdisk = fdisk[a:b]
shell_call('sudo lvremove -y ' + fdisk)

# 3 sudo vgscan
vg = shell_call("sudo vgscan")
a = vg.find("volume group") + len("volume group \"")
b = vg[a:].find("\" using") + a
vg = vg[a:b]
shell_call("sudo vgremove " + vg)

# 4 sudo wipefs --force --all /dev/sdb
shell_call("sudo wipefs --force --all /dev/sdb")

# 5 Finally Check all
shell_call("sudo lvdisplay -C -o lv_path")
shell_call("sudo fdisk -l")
shell_call("sudo vgscan")