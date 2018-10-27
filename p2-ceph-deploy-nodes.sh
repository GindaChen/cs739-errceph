NODES=(node0 node1 node2)

# Remove all the things we have... sad
# ceph-deploy purge $NODES
# ceph-deploy purgedata $NODES
# ceph-deploy forgetkeys $NODES
# rm ceph.*


# Basic Setups for ceph-deploy
ceph-deploy new 	$NODES
ceph-deploy install $NODES
ceph-deploy mon create-initial
ceph-deploy admin 	$NODES

# Change ownership if needed (most of the time I'm using the original user...)
sudo cp ceph* /etc/ceph
sudo chown $(whoami) -R /etc/ceph

# Create osd
## Execute prepare disk before this step only for node0
## Don't execute the prepare disk for the other nodes
# for i in $NODES; do
# 	ceph-deploy osd create --filestore --data /dev/sdb1  --journal /dev/sdc1 $i
# done

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
