# Copy snapshots except the journal file
NEWD=$(date +%H%M%S)
for NODE in 0 1 2; do
	sudo mkdir -p /home/yli/snapshot/${NEWD}
	rsync --exclude='journal' -r  ceph-node${NODE}:/var/lib/ceph/osd/ceph-${NODE}.snapshot  /home/yli/snapshot/
done