CEPHVERSION=debian-mimic

# Apt-get common packages
sudo apt-get install zsh git -y

wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
echo deb https://download.ceph.com/$CEPHVERSION/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
sudo apt update
sudo apt install ceph-deploy -y
sudo apt install ntp -y


# Customize: zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# # Change zsh Theme to jreese (so that we can see the node)
cat $HOME/.zshrc | sed 's/^ZSH_THEME=.*/ZSH_THEME="jreese"/' > $HOME/.zshrc_temp
cp $HOME/.zshrc $HOME/.zshrc.back
cp $HOME/.zshrc_temp $HOME/.zshrc 
# cp $HOME/.zshrc.back $HOME/.zshrc


