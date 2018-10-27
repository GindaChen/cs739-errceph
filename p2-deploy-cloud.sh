# Google cloud deploy

LOWNODENUM=0
HIGHNODENUM=2
# GSYSTEM="ubuntu-1404-trusty-v20181022"
GSYSTEM="ubuntu-1604-xenial-v20181023"

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
	--boot-disk-device-name=node0 \
	--create-disk=mode=rw,auto-delete=yes,size=100,name=hdd$i-1 \
	--create-disk=mode=rw,auto-delete=yes,size=100,name=hdd$i-2 \
done

# Disk Create
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	# gcloud compute --project=studious-spot-218900 disks create hdd$i-0 --zone=us-east4-c --type=pd-standard --size=100GB
	gcloud compute --project=studious-spot-218900 disks create hdd$i-1 --zone=us-east4-c --type=pd-standard --size=100GB
	gcloud compute --project=studious-spot-218900 disks create hdd$i-2 --zone=us-east4-c --type=pd-standard --size=100GB
done

# Disk Attach
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	# gcloud compute --project=studious-spot-218900 instances attach-disk node$i --zone=us-east4-c  --disk=hdd$i-0
	gcloud compute --project=studious-spot-218900 instances attach-disk node$i --zone=us-east4-c  --disk=hdd$i-1
	gcloud compute --project=studious-spot-218900 instances attach-disk node$i --zone=us-east4-c  --disk=hdd$i-2
done

# Disk Detach
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	# gcloud compute --project=studious-spot-218900 instances attach-disk node$i --zone=us-east4-c  --disk=hdd$i-0
	gcloud compute --project=studious-spot-218900 instances detach-disk node$i --zone=us-east4-c  --disk=hdd$i-1
	gcloud compute --project=studious-spot-218900 instances detach-disk node$i --zone=us-east4-c  --disk=hdd$i-2
done

# Start all 
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	gcloud compute instances start --async --zone=us-east4-c node$i
done

# Stop all
for i in `seq $LOWNODENUM $HIGHNODENUM`; do
	gcloud compute instances stop --async --zone=us-east4-c node$is
done
