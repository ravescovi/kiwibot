sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade

sudo apt-get install -y python-tk python-sip vim git terminator python-pip python-dev \
python-virtualenv screen tmux openssh-server libssl-dev libusb-1.0-0-dev libgtk-3-dev libglfw3-dev

mkdir ~/workspace
cd workspace

mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash

# Ian--added the following to get add-apt-repository
sudo apt-get install software-properties-common
sudo apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
sudo add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u
sudo apt-get update
version="2.33.1-0~realsense0.2140"
sudo apt-get -y install librealsense2-udev-rules=${version}
sudo apt-get -y install librealsense2-dkms=1.3.11-0ubuntu1
sudo apt-get -y install librealsense2=${version}

# Note the following four commands gives an error like the following 
# The following packages have unmet dependencies:
# librealsense2-gl : Depends: librealsense2 (= 2.33.1-0~realsense0.2140) but 2.45.0-0~realsense0.4550 is to be installed
# E: Unable to correct problems, you have held broken packages.
sudo apt-get -y install librealsense2-gl=${version}
sudo apt-get -y install librealsense2-utils=${version}
sudo apt-get -y install librealsense2-dev=${version}
sudo apt-get -y install librealsense2-dbg=${version}

sudo apt-mark hold librealsense2*

#https://github.com/IntelRealSense/librealsense/blob/master/doc/installation.md


export ENV=ianbot2

conda create -n $ENV python=3.8

##no idea why the path continally gets broken
PATH=$(echo "$PATH" | sed -e 's|/home/locobot/.local/bin||')


conda activate $ENV

conda config --env --add channels conda-forge
conda config --env --add channels robostack
conda config --env --add channels pytorch
conda config --env --set channel_priority strict

##INSTALLING ROS
## https://github.com/RoboStack/ros-noetic
conda install ros-noetic-desktop
conda install pytorch torchvision

conda install compilers cmake pkg-config make ninja catkin_tools

conda deactivate    
conda activate $ENV


##Starting ROSDEP
# if you want to use rosdep, also do:
#mamba install rosdep
rosdep init  # note: do not use sudo!
rosdep update

cd ~/workspace

git clone https://github.com/facebookresearch/pyrobot.git
cd pyrobot
git checkout master
git submodule update --init --recursive

cd ~/workspace/pyrobot/robots/LoCoBot/locobot_description/urdf
ln interbotix_locobot_description.urdf locobot_description.urdf
cd ~/workspace/pyrobot/robots/LoCoBot/locobot_moveit_config/config
ln interbotix_locobot.srdf locobot.srdf
cd ~/workspace/pyrobot/robots/LoCoBot/locobot_control/src

sed -i 's/\(float restJnts\[5\] = \)\(.*\)/\1{0, -1.30, 1.617, 0.5, 0};/' locobot_controller.cpp

if [ ! -d "~/workspace/pyrobot/robots/LoCoBot/thirdparty" ]; then

  	cd ~/workspace/pyrobot/robots/LoCoBot
  	mkdir thirdparty
  	cd thirdparty
		git clone https://github.com/AutonomyLab/create_autonomy
		git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench.git
		git clone https://github.com/ROBOTIS-GIT/DynamixelSDK.git
		git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench-msgs.git
		git clone https://github.com/ros-controls/ros_control.git
		git clone https://github.com/kalyanvasudev/ORB_SLAM2.git
		git clone https://github.com/s-gupta/ar_track_alvar.git

		cd create_autonomy && git checkout 90e597ea4d85cde1ec32a1d43ea2dd0b4cbf481c && cd ..
		cd dynamixel-workbench && git checkout bf60cf8f17e8385f623cbe72236938b5950d3b56 && cd ..
		cd DynamixelSDK && git checkout 05dcc5c551598b4d323bf1fb4b9d1ee03ad1dfd9 && cd ..
		cd dynamixel-workbench-msgs && git checkout 93856f5d3926e4d7a63055c04a3671872799cc86 && cd ..
		cd ros_control && git checkout cd39acfdb2d08dc218d04ff98856b0e6a525e702 && cd ..
		cd ORB_SLAM2 && git checkout ec8d750d3fc813fe5cef82f16d5cc11ddfc7bb3d && cd ..
		cd ar_track_alvar && git checkout a870d5f00a548acb346bfcc89d42b997771d71a3 && cd ..
fi

cd ~/workspace/
rosdep update 

# Following gives error:
#  ERROR: the following packages/stacks could not have their rosdep keys resolved
#  to system dependencies:
#  ca_driver: Cannot locate rosdep definition for [libcreate]
# Maybe relevant?
# https://answers.ros.org/question/336247/problems-installing-the-create_autonomy-package-on-ubuntu-1404/
rosdep install --from-paths pyrobot -i -y


##DROIDLET Installation
git clone --recursive https://github.com/facebookresearch/droidlet.git
cd droidlet

pip install -r \
    locobot/requirements.txt
python setup.py develop 



cd ~/workspace/pyrobot/robots/LoCoBot
sudo cp udev_rules/*.rules /etc/udev/rules.d
sudo service udev reload
sudo service udev restart
sudo udevadm trigger
sudo usermod -a -G dialout $USER
