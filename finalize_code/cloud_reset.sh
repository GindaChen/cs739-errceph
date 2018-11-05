################
# Cloud Reset
# The series of code deals with how to reset the cloud 
################

# Create Snapshot: If you want to create
# disks="ceph-deploy ceph-node0 ceph-node1 ceph-node2 disk-1 disk-2 disk-3 disk-4 disk-5 disk-6"
# EVENT="setuped"
# disks_snap="ceph-deploy-$EVENT,ceph-node0-$EVENT,ceph-node1-$EVENT,ceph-node2-$EVENT,disk-1-$EVENT,disk-2-$EVENT,disk-3-$EVENT,disk-4-$EVENT,disk-5-$EVENT,disk-6"
# gcloud compute disks snapshot $disks --async --description=ihateceph --snapshot-names $disks_snap --zone="us-east1-b"
# gcloud compute disks snapshot $disks --async --description=ihateceph --snapshot-names $disks_snap --zone="us-east1-b"


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