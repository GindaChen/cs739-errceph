# Install dependencies in gcloud
sudo apt-get install make -y

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

# Clone the CORDS into the repo
git clone https://github.com/GindaChen/cs739-errceph.git

# # c. App Binary (ZooKeeper)
# wget http://www.webhostingreviewjam.com/mirror/apache/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz; 
# tar -xvzf zookeeper-3.4.8.tar.gz

