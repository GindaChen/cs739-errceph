# Google cloud deploy

# Configurate 3 Nodes: node[0-2]
LOWNODENUM=0
HIGHNODENUM=2

# Specify System 
# GSYSTEM="ubuntu-1404-trusty-v20181022"
GSYSTEM="ubuntu-1604-xenial-v20181023"

DISKSIZE=5

# Call All
for i `seq $LOWNODENUM $HIGHNODENUM`; do
	ssh node$i ""
done

# Instance Create
for i in `seq $LOWNODENUM $HIGHNODENUM`; do	
	gcloud beta compute \
	--project=studious-spot-218900 instances create node$i \
	--zone=us-east4-c \
	--machine-type=g1-small \
	--subnet=default \
	--network-tier=PREMIUM \
	--maintenance-policy=MIGRATE \
	--service-account=983952798645-compute@developer.gserviceaccount.com \
	--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
	--image=$GSYSTEM \
	--image-project=ubuntu-os-cloud \
	--boot-disk-size=10GB \
	--boot-disk-type=pd-ssd \
	--boot-disk-device-name=node$i \
	--create-disk=mode=rw,auto-delete=yes,size=$DISKSIZE,name=hdd$i-1 \
	--create-disk=mode=rw,auto-delete=yes,size=$DISKSIZE,name=hdd$i-2 \
	--create-disk=mode=rw,auto-delete=yes,size=$DISKSIZE,name=hdd$i-3 \
done

# Disk Create
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	# gcloud compute --project=studious-spot-218900 disks create hdd$i-0 --zone=us-east4-c --type=pd-standard --size=${DISKSIZE}GB
	gcloud compute --project=studious-spot-218900 disks create hdd$i-1 --zone=us-east4-c --type=pd-standard --size=${DISKSIZE}GB
	gcloud compute --project=studious-spot-218900 disks create hdd$i-2 --zone=us-east4-c --type=pd-standard --size=${DISKSIZE}GB
	gcloud compute --project=studious-spot-218900 disks create hdd$i-3 --zone=us-east4-c --type=pd-standard --size=${DISKSIZE}GB
done

# Disk Attach
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	# gcloud compute --project=studious-spot-218900 instances attach-disk node$i --zone=us-east4-c  --disk=hdd$i-0
	gcloud compute --project=studious-spot-218900 instances attach-disk node$i --zone=us-east4-c  --disk=hdd$i-1
	gcloud compute --project=studious-spot-218900 instances attach-disk node$i --zone=us-east4-c  --disk=hdd$i-2
	gcloud compute --project=studious-spot-218900 instances attach-disk node$i --zone=us-east4-c  --disk=hdd$i-3
done

# Disk Detach
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	# gcloud compute --project=studious-spot-218900 instances attach-disk node$i --zone=us-east4-c  --disk=hdd$i-0
	gcloud compute --project=studious-spot-218900 instances detach-disk node$i --zone=us-east4-c  --disk=hdd$i-1
	gcloud compute --project=studious-spot-218900 instances detach-disk node$i --zone=us-east4-c  --disk=hdd$i-2
	gcloud compute --project=studious-spot-218900 instances detach-disk node$i --zone=us-east4-c  --disk=hdd$i-3
done

# Start all 
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	gcloud compute instances start --async --zone=us-east4-c node$i
done

# Stop all
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	gcloud compute instances stop --async --zone=us-east4-c node$is
done


# Create Snapshot
# In Yuanchen's Computer
disks="ceph-deploy ceph-node0 ceph-node1 ceph-node2 disk-1 disk-2 disk-3 disk-4 disk-5 disk-6"
disks_snap="ceph-deploy,ceph-node0,ceph-node1,ceph-node2,disk-1,disk-2,disk-3,disk-4,disk-5,disk-6"
gcloud compute disks snapshot $disks --async --description=ihateceph --snapshot-names $disks_snap --zone="us-east1-b"

# In mine
# disks="node0 node1 node2 hdd0-1 hdd0-2 hdd0-3 hdd1-1 hdd1-2 hdd1-3 hdd2-1 hdd2-2 hdd2-3"
# disks_snap="node0,node1,node2,hdd0-1,hdd0-2,hdd0-3,hdd1-1,hdd1-2,hdd1-3,hdd2-1,hdd2-2,hdd2-3"
# disks="node0 node1 node2"
# disks_snap="node0,node1,node2"
# gcloud compute disks snapshot $disks --async --description=nodeinit --snapshot-names $disks_snap --zone="us-east1-b"


# Revert Snapshot
# 1 Remove all instances
# https://console.cloud.google.com/compute/instances?project=quickstep-219304&duration=PT1H

# 2 Remove all disks


# 3 Recreate all disks
gcloud compute disks create disk-1 --size=50 --source-snapshot=disk-1 --type=pd-standard
gcloud compute disks create disk-2 --size=10 --source-snapshot=disk-2 --type=pd-standard
gcloud compute disks create disk-3 --size=50 --source-snapshot=disk-3 --type=pd-standard
gcloud compute disks create disk-4 --size=10 --source-snapshot=disk-4 --type=pd-standard
gcloud compute disks create disk-5 --size=50 --source-snapshot=disk-5 --type=pd-standard
gcloud compute disks create disk-6 --size=10 --source-snapshot=disk-6 --type=pd-standard

# 4 Recreate all instances
echo Recreate ceph-deploy
gcloud compute --project "quickstep-219304" disks create "ceph-deploy" --size "100" --zone "us-east1-b" --source-snapshot "ceph-deploy" --type "pd-standard"
gcloud beta compute --project=quickstep-219304 instances create ceph-deploy --zone=us-east1-b --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=463049735650-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --disk=name=ceph-deploy,device-name=ceph-deploy,mode=rw,boot=yes,auto-delete=yes
echo Recreate ceph-node0
gcloud compute --project "quickstep-219304" disks create "ceph-node0" --size "100" --zone "us-east1-b" --source-snapshot "ceph-node0" --type "pd-standard"
gcloud beta compute --project=quickstep-219304 instances create ceph-node0 --zone=us-east1-b --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=463049735650-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --disk=name=ceph-node0,device-name=ceph-node0,mode=rw,boot=yes,auto-delete=yes --disk=name=disk-1,device-name=disk-1,mode=rw,boot=no,auto-delete=yes --disk=name=disk-2,device-name=disk-2,mode=rw,boot=no,auto-delete=yes
echo Recreate ceph-node1
gcloud compute --project "quickstep-219304" disks create "ceph-node1" --size "100" --zone "us-east1-b" --source-snapshot "ceph-node1" --type "pd-standard"
gcloud beta compute --project=quickstep-219304 instances create ceph-node1 --zone=us-east1-b --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=463049735650-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --disk=name=ceph-node1,device-name=ceph-node1,mode=rw,boot=yes,auto-delete=yes --disk=name=disk-3,device-name=disk-3,mode=rw,boot=no,auto-delete=yes --disk=name=disk-4,device-name=disk-4,mode=rw,boot=no,auto-delete=yes
echo Recreate ceph-node2
gcloud compute --project "quickstep-219304" disks create "ceph-node2" --size "100" --zone "us-east1-b" --source-snapshot "ceph-node2" --type "pd-standard"
gcloud beta compute --project=quickstep-219304 instances create ceph-node2 --zone=us-east1-b --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=463049735650-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --disk=name=ceph-node2,device-name=ceph-node2,mode=rw,boot=yes,auto-delete=yes --disk=name=disk-5,device-name=disk-5,mode=rw,boot=no,auto-delete=yes --disk=name=disk-6,device-name=disk-6,mode=rw,boot=no,auto-delete=yes

# 5 Remove .ssh/known_hosts and try to ssh again to all nodes.
LOWNODENUM=0
HIGHNODENUM=2
NODES=(ceph-node0 ceph-node1 ceph-node2)
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	echo '\e[93m$ ssh ceph-node$i echo Test ssh link \e[0m'
	ssh ceph-node$i echo 'test ssh link in $(whoami)@$(hostname)'
done