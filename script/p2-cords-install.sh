# Install dependencies in gcloud
sudo apt-get install make -y
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk 

mkdir dependencies
cd dependencies

# a. Install FUSE lib
wget https://github.com/libfuse/libfuse/releases/download/fuse-2.9.7/fuse-2.9.7.tar.gz; 
tar -xvzf fuse-2.9.7.tar.gz; 
cd fuse-2.9.7/; 
./configure; 
make -j33; 
sudo make install;
cd ..;

# b. Install g++
sudo apt-get install -y gcc-5 g++-5; 
sudo update-alternatives; 
sudo update-alternatives --remove-all gcc; 
sudo update-alternatives --remove-all g++; 
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 20; 
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 20; 
sudo update-alternatives --config gcc; sudo update-alternatives --config g++;
g++ -v

# Clone the CORDS into the repo (Everything here is a persist version...)
git clone https://github.com/GindaChen/cs739-errceph.git
cp -r cs739-errceph/cords .



# # c. App Binary (ZooKeeper)
# wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz;
wget https://apache.org/dist/zookeeper/zookeeper-3.4.12/zookeeper-3.4.12.tar.gz;
# tar -xvzf zookeeper-3.4.8.tar.gz
tar -xvzf zookeeper-3.4.12.tar.gz
cp -r zookeeper-3.4.12 ~
cd ..