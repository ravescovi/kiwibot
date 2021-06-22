##dist upgrade

sudo apt update
sudo usermod -aG sudo raf

##Cleaning playground
cd ~
rm -rf Music/ Public/ Videos/ Templates/ Pictures/ Documents/ examples.desktop

sudo apt remove --purge -y snapd gnome-software-plugin-snap gnome-calculator 
sudo apt remove --purge -y gnome-characters  gnome-getting-started-docs 
sudo apt remove --purge -y gnome-mahjongg  gnome-mines gnome-screenshot gnome-sudoku
sudo apt remove --purge -y gnome-todo gnome-user-* 
sudo apt remove --purge -y thunderbird remmina firefox compton leafpad clipit rhythmbox
sudo apt remove --purge -y libreoffice-*
sudo apt remove --purge -y cups cups-browsed avahi-daemon
sudo apt remove --purge -y gnome-software ## What does this removes!!??
sudo apt remove --purge -y firefox cups cups-browsed avahi-daemon avahi-autoipd
sudo apt remove --purge -y aisleriot gnome-calendar 
sudo apt remove --purge -y cheese deja-dup seahorse shotwell gnome-video-effects 
sudo apt remove --purge -y imagemagick transmission onboard
sudo apt remove --purge -y printer-driver-* libavahi* 
#sudo apt remove --purge -y xserver-xorg-input-wacom xserver-xorg-video-amdgpu xserver-xorg-video-ati xserver-xorg-video-radeon
sudo apt remove --purge -y chromium-browser chromium-browser-l10n

sudo chmod -x /usr/lib/evolution/evolution-calendar-factory # less dirty hack
##sudo apt install localepurge ##kind of annoying, find a better way
#sudo dpkg --purge --force-all libopencv-dev ##Curious behaviour

sudo apt autoremove --purge -y
sudo apt upgrade -y



sudo sed -i 's/Prompt=never/Prompt=lts/g' /etc/update-manager/release-upgrades
sudo reboot -n

do-release-upgrade

sudo apt remove --purge -y snapd firefox cups cups-browsed avahi-daemon
sudo apt remove --purge -y aisleriot gnome-calendar 
sudo apt remove --purge -y cheese deja-dup seahorse shotwell gnome-video-effects 
sudo apt remove --purge -y imagemagick transmission onboard

sudo apt upgrade -y
sudo apt --fix-broken install

sudo apt-add-repository universe
sudo apt-add-repository multiverse
sudo apt-add-repository restricted


sudo apt install -y python-is-python3 tmux python3-pip python-opencv
sudo -H pip install -U jetson-stats


mkdir ~/workspace


#NX playground
sudo apt-get install xserver-xorg-video-dummy

cd workspace
wget https://download.nomachine.com/download/7.6/Arm/nomachine_7.6.2_3_arm64.deb
sudo dpkg -i nomachine_7.6.2_3_arm64.deb 

sudo vi /etc/X11/xorg.conf ## create virtual display??
sudo vi /etc/X11/default-display-manager

   
#sudo systemctl set-default multi-user.target



sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt update

sudo apt install -y ros-noetic-ros-base  ros-noetic-desktop-full
sudo apt-get install python3-rosdep

sudo rosdep init
rosdep update


sudo apt install -y python3-rosinstall python3-rosinstall-generator python3-wstool 
sudo apt install -y ros-noetic-pybind11-catkin ros-noetic-moveit ros-noetic-ddynamic-reconfigure
sudo apt install -y ros-noetic-kdl-parser-py ros-noetic-trac-ik 
sudo apt install -y ros-noetic-rospy-message-converter python3-catkin python3-catkin-tools

echo "source /opt/ros/noetic/setup.sh" > ~/.bashrc
source ~/.bashrc

sudo apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo bionic main" -u

sudo apt update
sudo apt install librealsense2*


##pyrobot
## no need for azure (ms camera )
#curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
#sudo apt-add-repository https://packages.microsoft.com/ubuntu/20.04/multiarch/prod
#sudo apt-get update
###???
###libk4a1.4 ros-noetic-orocos-kdl

sudo apt install -y ninja-build

cd ~/workspace/
git clone https://github.com/Jekyll1021/pyrobot.git
cd pyrobot/
git checkout pyrobot-noetic
pip install -e .




