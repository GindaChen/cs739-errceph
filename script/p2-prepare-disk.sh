# Prepare all disks
if [[ $(whoami) != "root" ]]; then
	echo Please use root to execute all the commands 
	exit
fi

lsblk
blkid

sudo mkfs.xfs -f /dev/sdb
sudo mkfs.xfs -f /dev/sdc

systemctl enable lvm2-lvmetad.service
systemctl enable lvm2-lvmetad.socket
systemctl start lvm2-lvmetad.service
systemctl start lvm2-lvmetad.socket



PART="/dev/sdb"
parted $PART --script -- mklabel gpt
parted --script $PART mkpart primary xfs 0% 100%
# parted --script $PART rm 1


PART="/dev/sdc"
parted $PART --script -- mklabel gpt 
parted --script $PART mkpart primary xfs 0% 100%

PART="/dev/sdd"
parted $PART --script -- mklabel gpt 
parted --script $PART mkpart primary xfs 0% 100%

pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1
vgcreate data /dev/sdb1 /dev/sdc1 

lsblk

# Remove All disks
lvremove /dev/ceph*
