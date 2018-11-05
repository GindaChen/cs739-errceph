# Part 0

NODES=(node0 node1 node2)
NODES=(ceph-node0 ceph-node1 ceph-node2)

addnode(){
	echo "export NODES=(node0 node1 node2)" > ~/.zshstart
	echo "export NODES=(ceph-node0 ceph-node1 ceph-node2)" > ~/.zshstart
	tail ~/.zshstart
	echo "source ~/.zshstart" >> ~/.zshrc
	tail ~/.zshrc
	echo $NODES
}

callall(){ # Function template to call all the nodes
	for i `seq $LOWNODENUM $HIGHNODENUM`; do
		ssh ceph-node$i "$1"
	done
}


# Remove all the things we have... sad
purgeall(){
	# ceph-deploy purge node0 node1 node2
	ceph-deploy purge $NODES
	# ceph-deploy purgedata node0 node1 node2
	ceph-deploy purgedata $NODES
	# ceph-deploy forgetkeys node0 node1 node2
	ceph-deploy forgetkeys $NODES
	rm ceph.*
	# Make sure the purgeme.py is in ceph-deploy:~/
	for i in $NODES; do
		echo Copy purgeme.py to $i
		scp ~/purgeme.py $i:~/
		echo Purging $i ...
		ssh $i python ~/purgeme.py
	done
}


# Basic Setups for ceph-deploy
ceph-deploy new 	$NODES
ceph-deploy install $NODES
ceph-deploy mon --overwrite-conf create-initial
ceph-deploy admin 	$NODES
# Prevent Object Name too long on disk
echo 'osd_check_max_object_name_len_on_startup = false' >> ceph.conf
ceph-deploy --overwrite-conf config push $NODES #node0 node1 node2
# Change ownership if needed (most of the time I'm using the original user...)
sudo cp ceph* /etc/ceph
sudo chown $(whoami) -R /etc/ceph

# Create osd
## Execute prepare disk before this step only for node0
## Don't execute the prepare disk for the other nodes
# for i in $NODES; do
# 	ceph-deploy osd create --filestore --data /dev/sdb1  --journal /dev/sdc1 $i
# done


# sudo su
diskParted(){
	lsblk
	sudo mkfs.xfs -f /dev/sdb; sudo mkfs.xfs -f /dev/sdc; sudo mkfs.xfs -f /dev/sdd;
	systemctl enable lvm2-lvmetad.service; systemctl enable lvm2-lvmetad.socket; 
	systemctl start lvm2-lvmetad.service;  systemctl start lvm2-lvmetad.socket;
	PARTS=("/dev/sdb" "/dev/sdc" "/dev/sdd")
	for PART in $PARTS; do
		parted $PART --script -- mklabel gpt
		parted --script $PART mkpart primary xfs 0% 100%
	done
	# PART="/dev/sdb"; parted $PART --script -- mklabel gpt; parted --script $PART mkpart primary xfs 0% 100%
	# PART="/dev/sdc"; parted $PART --script -- mklabel gpt; parted --script $PART mkpart primary xfs 0% 100%
	# PART="/dev/sdd"; parted $PART --script -- mklabel gpt; parted --script $PART mkpart primary xfs 0% 100%
	pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1
	echo Please use 
	echo sudo su
}

ceph-deploy osd create --filestore --data /dev/sdb1  --journal /dev/sdc1 node0
ceph-deploy osd create --filestore --data /dev/sdb1  --journal /dev/sdc1 node1
ceph-deploy osd create --filestore --data /dev/sdb1  --journal /dev/sdc1 node2

# ceph-deploy mgr create $NODES
ceph-deploy mgr create node0

# By now, we should expext that ceph health is okay. 
# Otherwise we maybe should not enter the next step
if [[ $(ceph health) != "HEALTH_OK" ]]; then
 	echo Ceph health no ok
fi 

# Check Ceph Status
## ceph osd df # 
# ceph stats

# Initial Snapshot of all disks
# Create Snapshot
# In Yuanchen's Computer
disks="ceph-deploy ceph-node0 ceph-node1 ceph-node2" #disk-1 disk-2 disk-3 disk-4 disk-5 disk-6"
disks_snap="ceph-deploy,ceph-node0,ceph-node1,ceph-node2" #,disk-1,disk-2,disk-3,disk-4,disk-5,disk-6"
gcloud compute disks snapshot $disks --async --description=ihateceph --snapshot-names $disks_snap --zone="us-east1-b"

# In Mike
# disks="node0 node1 node2 hdd0-1 hdd0-2 hdd0-3 hdd1-1 hdd1-2 hdd1-3 hdd2-1 hdd2-2 hdd2-3"
# disks_snap="node0,node1,node2,hdd0-1,hdd0-2,hdd0-3,hdd1-1,hdd1-2,hdd1-3,hdd2-1,hdd2-2,hdd2-3"
# disks="node0 node1 node2"
# disks_snap="node0,node1,node2"
# gcloud compute disks snapshot $disks --async --description=nodeinit --snapshot-names $disks_snap --zone="us-east1-b"


# Part 1
# Run some data
sudo systemctl start ceph-osd@0
sudo systemctl start ceph-osd@1
sudo systemctl start ceph-osd@2
sudo ceph osd tree # Make sure all are exist,up

cd ~
sudo ceph osd pool create scbench 100 100
cd ~/workloads
python initial_data.py
# python remotetrace.py --trace_files /home/ceph/trace0 /home/ceph/trace1 /home/ceph/trace2 \
# --data_dirs /var/lib/ceph/osd/ceph-0 /var/lib/ceph/osd/ceph-1 /var/lib/ceph/osd/ceph-2 \
# --machines ceph-node0 ceph-node1 ceph-node2 \
# --workload_command 'python initial_data.py'

# Stop all osd
sudo systemctl stop ceph-osd@0
sudo systemctl stop ceph-osd@1
sudo systemctl stop ceph-osd@2

# Create Snapshots
cd  /var/lib/ceph/osd
sudo -u ceph cp -r /var/lib/ceph/osd/ceph-0 /var/lib/ceph/osd/ceph-0.snapshot
diff /var/lib/ceph/osd/ceph-0 /var/lib/ceph/osd/ceph-0.snapshot

cd  /var/lib/ceph/osd
sudo -u ceph cp -r /var/lib/ceph/osd/ceph-1 /var/lib/ceph/osd/ceph-1.snapshot
diff /var/lib/ceph/osd/ceph-1 /var/lib/ceph/osd/ceph-1/.snapshot

cd  /var/lib/ceph/osd
sudo -u ceph cp -r /var/lib/ceph/osd/ceph-2 /var/lib/ceph/osd/ceph-2.snapshot
diff /var/lib/ceph/osd/ceph-2 /var/lib/ceph/osd/ceph-2.snapshot


# Make Mount Point
sudo -u ceph mkdir -p /var/lib/ceph/osd/ceph-0.mp; la
sudo -u ceph mkdir -p /var/lib/ceph/osd/ceph-1.mp; la
sudo -u ceph mkdir -p /var/lib/ceph/osd/ceph-2.mp; la

# Mount errfs and generate trace file
sudo -u ceph \
/home/yli/cords/CORDS/errfs -f -oallow_other,modules=subdir,subdir=/var/lib/ceph/osd/ceph-0 \
/var/lib/ceph/osd/ceph-0.mp \
trace /home/ceph/trace0 &

sudo -u ceph \
/home/yli/cords/CORDS/errfs -f -oallow_other,modules=subdir,subdir=/var/lib/ceph/osd/ceph-1 \
/var/lib/ceph/osd/ceph-1.mp \
trace /home/ceph/trace1 &

sudo -u ceph \
/home/yli/cords/CORDS/errfs -f -oallow_other,modules=subdir,subdir=/var/lib/ceph/osd/ceph-2 \
/var/lib/ceph/osd/ceph-2.mp \
trace /home/ceph/trace2 &

# Start all osd
sudo systemctl start ceph-osd@0
sudo systemctl start ceph-osd@1
sudo systemctl start ceph-osd@2
sudo ceph osd status
sudo ceph osd tree

# Real Work load: write and read a-z 26 blocks
cd ~/scripts
python remotetrace.py --trace_files /home/ceph/trace0 /home/ceph/trace1 /home/ceph/trace2 \
--data_dirs /var/lib/ceph/osd/ceph-0 /var/lib/ceph/osd/ceph-1 /var/lib/ceph/osd/ceph-2 \
--machines ceph-node0 ceph-node1 ceph-node2 \
--workload_command 'python ../workloads/read_data.py'

# Unmount errfs 
# Work pool create and work load Initial
# Node0

# Stop osd and Unmount osd
sudo systemctl stop ceph-osd@0
sudo fusermount -u /var/lib/ceph/osd/ceph-0.mp
sudo systemctl stop ceph-osd@1
sudo fusermount -u /var/lib/ceph/osd/ceph-1.mp
sudo systemctl stop ceph-osd@2
sudo fusermount -u /var/lib/ceph/osd/ceph-2.mp

# cd /home/ceph
# sudo -u ceph mkdir arx
# sudo -u ceph mv j* t* arx

for i in 0 1 2; do
	scp -r ceph-node$i:/home/ceph/trace* ~/trace
done


# After Unmount: revert Snapshot
sudo su
cd /var/lib/ceph/osd/ceph-0/
sudo rm -rf /var/lib/ceph/osd/ceph-0/*
sudo -u ceph cp -r /var/lib/ceph/osd/ceph-0.snapshot/* /var/lib/ceph/osd/ceph-0/
# sudo -u ceph cp -r  ../ceph-0.snapshot/* .
# cd ..
cd /var/lib/ceph/osd/
# diff -r ceph-0 ceph-0.snapshot
diff -r /var/lib/ceph/osd/ceph-0 /var/lib/ceph/osd/ceph-0.snapshot

sudo su
cd /var/lib/ceph/osd/ceph-1/
sudo rm -rf /var/lib/ceph/osd/ceph-1/*
sudo -u ceph cp -r /var/lib/ceph/osd/ceph-1.snapshot/* /var/lib/ceph/osd/ceph-1/
# sudo -u ceph cp -r ../ceph-1.snapshot/* .
cd /var/lib/ceph/osd/
# diff -r ceph-1 ceph-1.snapshot
diff -r /var/lib/ceph/osd/ceph-1 /var/lib/ceph/osd/ceph-1.snapshot


sudo su
cd /var/lib/ceph/osd/ceph-2/
sudo rm -rf /var/lib/ceph/osd/ceph-2/*
sudo -u ceph cp -r  ../ceph-2.snapshot/* .
# cd ..
cd /var/lib/ceph/osd/
# diff -r ceph-2 ceph-2.snapshot
diff -r /var/lib/ceph/osd/ceph-2 /var/lib/ceph/osd/ceph-2.snapshot


# Before Test run: Set ceph config file
sudo su
# Init Config
# cd /etc/ceph
# cp ceph.conf  ceph.conf.complete
# cp ceph.conf  ceph.conf.error
# vim ceph.conf.error
# cp ceph.conf.error ceph.conf  
# cat ceph.conf

# Revert to initial
cd /etc/ceph
cp ceph.conf.complete  ceph.conf
cat ceph.conf

# Set error
cd /etc/ceph
cp ceph.conf.error  ceph.conf
cat ceph.conf

sudo ceph osd status
sudo ceph osd tree

# Start OSD
sudo systemctl start ceph-osd@0
sudo systemctl start ceph-osd@1
sudo systemctl start ceph-osd@2

sudo ceph osd status
sudo ceph osd tree

# Stop OSD
sudo systemctl stop ceph-osd@0
sudo systemctl stop ceph-osd@1
sudo systemctl stop ceph-osd@2

# http://docs.ceph.com/docs/master/rados/operations/operating/
