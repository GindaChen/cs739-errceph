##########################
# main.sh
# All Main procedures are here
##########################

# --------------------
# Part 0: Env Setting
# --------------------

NODES=(ceph-node0 ceph-node1 ceph-node2) # Define all nodes

addnode(){ # Add all nodes to zsh config (no bash sorry)
	echo "export NODES=(node0 node1 node2)" > ~/.zshstart; echo "export NODES=(ceph-node0 ceph-node1 ceph-node2)" > ~/.zshstart;
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

# --------------------
# Part 1: Setup Ceph
# --------------------

# ---- Purge all -----
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


# ----- Setup Ceph -----
NODES=(ceph-node0 ceph-node1 ceph-node2) # Define all nodes
ceph-deploy new 	ceph-node0
ceph-deploy install $NODES
ceph-deploy mon --overwrite-conf create-initial
ceph-deploy admin 	$NODES

# Prevent Object Name too long on disk
echo 'osd_check_max_object_name_len_on_startup = false' >> ceph.conf
ceph-deploy --overwrite-conf config push $NODES

# Change ownership if needed (most of the time I'm using the original user...)
# sudo cp ceph* /etc/ceph
# sudo chown $(whoami) -R /etc/ceph

# ----- Partition Disks ( if we haven't ) -----
# sudo su
# diskParted(){
# 	lsblk
# 	sudo mkfs.xfs -f /dev/sdb; sudo mkfs.xfs -f /dev/sdc; sudo mkfs.xfs -f /dev/sdd;
# 	systemctl enable lvm2-lvmetad.service; systemctl enable lvm2-lvmetad.socket; 
# 	systemctl start lvm2-lvmetad.service;  systemctl start lvm2-lvmetad.socket;
# 	PARTS=("/dev/sdb" "/dev/sdc" "/dev/sdd")
# 	for PART in $PARTS; do
# 		parted $PART --script -- mklabel gpt
# 		parted --script $PART mkpart primary xfs 0% 100%
# 	done
# 	# PART="/dev/sdb"; parted $PART --script -- mklabel gpt; parted --script $PART mkpart primary xfs 0% 100%
# 	# PART="/dev/sdc"; parted $PART --script -- mklabel gpt; parted --script $PART mkpart primary xfs 0% 100%
# 	# PART="/dev/sdd"; parted $PART --script -- mklabel gpt; parted --script $PART mkpart primary xfs 0% 100%
# 	pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1
# 	echo Please use 
# 	echo sudo su
# }

# ----- Create Filestore and mgr -----
# ceph-deploy osd create --filestore --data /dev/sdb  --journal /dev/sdc1 ceph-node0
# ceph-deploy osd create --filestore --data /dev/sdb  --journal /dev/sdc1 ceph-node1
# ceph-deploy osd create --filestore --data /dev/sdb  --journal /dev/sdc1 ceph-node2

# ceph-deploy mgr create ceph-node0

# ----- Check Health -----
if [[ $(ceph health) != "HEALTH_OK" ]]; then
 	echo Ceph health no ok
fi 

ceph osd stats
ceph osd tree

# ----- (Local) Create Snapshot for the initstate (maybe not?) -----
# disks="ceph-deploy ceph-node0 ceph-node1 ceph-node2,disk-1 disk-2 disk-3 disk-4 disk-5 disk-6"
# disks_snap="ceph-deploy,ceph-node0,ceph-node1,ceph-node2,disk-1,disk-2,disk-3,disk-4,disk-5,disk-6"
# gcloud compute disks snapshot $disks --async --description=init --snapshot-names Init-$disks_snap --zone="us-east1-b"


# -----------------------------------
# Part 1: Prepare the initial state
#		for the CORDS to blow up
# -----------------------------------

# /var/lib/ceph/osd/ceph-0
# /var/lib/ceph/osd/ceph-0.mp
# /var/lib/ceph/osd/ceph-0.snapshot

# Some utilities
# cp /home/yli/.ssh/* ~/.ssh # grant sudo permission






# ------- 
# Step 1: Write the initial 26 objects with the python using Librados 
# ------- 

# In ceph-deploy
cd ~
sudo ceph osd pool create scbench 100 100

# Make sure all are exist,up
# sudo systemctl start ceph-osd@0
# sudo systemctl start ceph-osd@1
# sudo systemctl start ceph-osd@2
sudo ceph osd tree

cd ~/workloads
python initial_data.py




# ------- 
# Step 2: snapshot the state
# ------- 

# Create snapshot in Node 0, 1, 2
cd /var/lib/ceph/osd
ls /var/lib/ceph/osd/ceph-0.snapshot
mkdir -p /var/lib/ceph/osd/ceph-0.snapshot
cp -r /var/lib/ceph/osd/ceph-0/* /var/lib/ceph/osd/ceph-0.snapshot
diff -r /var/lib/ceph/osd/ceph-0/ /var/lib/ceph/osd/ceph-0.snapshot

cd /var/lib/ceph/osd
ls /var/lib/ceph/osd/ceph-1.snapshot
mkdir -p /var/lib/ceph/osd/ceph-1.snapshot
cp -r /var/lib/ceph/osd/ceph-1/* /var/lib/ceph/osd/ceph-1.snapshot
diff -r /var/lib/ceph/osd/ceph-1 /var/lib/ceph/osd/ceph-1.snapshot

cd /var/lib/ceph/osd
ls /var/lib/ceph/osd/ceph-2.snapshot
mkdir -p /var/lib/ceph/osd/ceph-2.snapshot
cp -r /var/lib/ceph/osd/ceph-2/* /var/lib/ceph/osd/ceph-2.snapshot
diff -r /var/lib/ceph/osd/ceph-2 /var/lib/ceph/osd/ceph-2.snapshot

# Copy the data back to ceph-deploy
# Copy snapshots (with root in ceph-deploy)
DATENOW=$(date +%d-%H%M%S)
mkdir -p /root/snapshots
mkdir -p /root/snapshots/snap-$DATENOW
mkdir -p /root/snapshots/snap-$DATENOW/ceph-0.snapshot
mkdir -p /root/snapshots/snap-$DATENOW/ceph-1.snapshot
mkdir -p /root/snapshots/snap-$DATENOW/ceph-2.snapshot
rsync --exclude='journal' -r ceph-node0:/var/lib/ceph/osd/ceph-0.snapshot/  /root/snapshots/snap-$DATENOW/ceph-0.snapshot
rsync --exclude='journal' -r ceph-node1:/var/lib/ceph/osd/ceph-1.snapshot/  /root/snapshots/snap-$DATENOW/ceph-1.snapshot
rsync --exclude='journal' -r ceph-node2:/var/lib/ceph/osd/ceph-2.snapshot/  /root/snapshots/snap-$DATENOW/ceph-2.snapshot


# ----- (Local) Create Snapshot for the initstate for CORDS -----
disks="ceph-deploy ceph-node0 ceph-node1 ceph-node2,disk-1 disk-2 disk-3 disk-4 disk-5 disk-6"
disks_snap="ceph-deploy,ceph-node0,ceph-node1,ceph-node2,disk-1,disk-2,disk-3,disk-4,disk-5,disk-6"
gcloud compute disks snapshot $disks --async --description=datawritten --snapshot-names Init-$disks_snap --zone="us-east1-b"


# ------- 
# Step 3: Stop all OSDs
# ------- 




# ------- 
# Step 4: Mount the errfs with trace mode and update the ceph config file
# -------


# ------- 
# Step 5: Run the workload (either the readonly version or the write/update version)
# ------- 


# ------- 
# Step 6: Stop all OSDs and restore the ceph config file
# ------- 


# ------- 
# Step 7: Unmount errfs
# ------- 


# ------- 
# Step 8: Retrieve traces
# ------- 


# -----------------------------------
# Part 2: 
#		
# -----------------------------------
