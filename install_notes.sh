sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade

sudo apt-get install -y python-tk python-sip vim git terminator python-pip python-dev
sudo apt-get install -y python-virtualenv screen tmux openssh-server libssl-dev libusb-1.0-0-dev libgtk-3-dev libglfw3-dev

mkdir ~/workspace
cd workspace

mkdir -p /miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash ./miniconda.sh -b -u -p ~/workspace/miniconda3
rm -rf ./miniconda.sh
./miniconda3/bin/conda init bash

##activating conda
bash


##Installing System libs
sudo apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
sudo add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u
sudo apt-get update
version="2.33.1-0~realsense0.2140"
sudo apt-get -y install librealsense2-udev-rules=${version}
sudo apt-get -y install librealsense2-dkms=1.3.11-0ubuntu1
sudo apt-get -y install librealsense2=${version}
sudo apt-get -y install librealsense2-gl=${version}
sudo apt-get -y install librealsense2-utils=${version}
sudo apt-get -y install librealsense2-dev=${version}
sudo apt-get -y install librealsense2-dbg=${version}
sudo apt-mark hold librealsense2*

#https://github.com/IntelRealSense/librealsense/blob/master/doc/installation.md


##downloading stuff
git clone https://github.com/facebookresearch/pyrobot.git
git clone --recursive https://github.com/facebookresearch/droidlet.git


export ENV=rafbot

conda create -y -n $ENV python=3.8
conda activate $ENV

conda config --env --add channels conda-forge
conda config --env --add channels robostack
conda config --env --add channels pytorch
conda config --env --set channel_priority strict

#Installing basic deps 
conda install -y numpy scipy matplotlib ipython Pillow 
conda install -y compilers cmake pkg-config make ninja catkin_tools


pip install -r ~/workspace/droidlet/locobot/requirements.txt

##pain1
#conda install -y opencv
#conda install -y open3d

##pain2
#conda install -y pytorch torchvision

##INSTALLING ROS
## https://github.com/RoboStack/ros-noetic
conda install -y ros-noetic-desktop
conda install -y ros-noetic-ddynamic-reconfigure
conda install -y ros-noetic-librealsense2

##this version of opencv breaks the installation but it is necessary for orb_slam2
##conda install -y -c conda-forge opencv==3.4.9

pip install bezier

conda deactivate    
conda activate $ENV



rosdep init 
rosdep update



git clone https://github.com/IntelRealSense/realsense-ros.git
cd realsense-ros/
git checkout 2.3.0

mkdir release
cd release

make clean
cmake ../realsense2_camera/  -DCMAKE_BUILD_TYPE=Release
sudo make install



cd ~/workspace/pyrobot
git checkout master
git submodule update --init --recursive

cd ~/workspace/pyrobot/robots/LoCoBot/locobot_description/urdf
ln interbotix_locobot_description.urdf locobot_description.urdf
cd ~/workspace/pyrobot/robots/LoCoBot/locobot_moveit_config/config
ln interbotix_locobot.srdf locobot.srdf
cd ~/workspace/pyrobot/robots/LoCoBot/locobot_control/src
sed -i 's/\(float restJnts\[5\] = \)\(.*\)/\1{0, -1.30, 1.617, 0.5, 0};/' locobot_controller.cpp



cd ~/workspace/pyrobot/robots/LoCoBot
mkdir thirdparty
cd thirdparty
git clone https://github.com/AutonomyLab/create_autonomy
git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench.git
git clone https://github.com/ROBOTIS-GIT/DynamixelSDK.git
git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench-msgs.git
git clone https://github.com/ros-controls/ros_control.git
#git clone https://github.com/kalyanvasudev/ORB_SLAM2.git
git clone https://github.com/s-gupta/ar_track_alvar.git

cd create_autonomy && git checkout 90e597ea4d85cde1ec32a1d43ea2dd0b4cbf481c && cd ..
cd dynamixel-workbench && git checkout bf60cf8f17e8385f623cbe72236938b5950d3b56 && cd ..
cd DynamixelSDK && git checkout 05dcc5c551598b4d323bf1fb4b9d1ee03ad1dfd9 && cd ..
cd dynamixel-workbench-msgs && git checkout 93856f5d3926e4d7a63055c04a3671872799cc86 && cd ..
cd ros_control && git checkout cd39acfdb2d08dc218d04ff98856b0e6a525e702 && cd ..
#cd ORB_SLAM2 && git checkout ec8d750d3fc813fe5cef82f16d5cc11ddfc7bb3d && cd ..
cd ar_track_alvar && git checkout a870d5f00a548acb346bfcc89d42b997771d71a3 && cd ..

git clone https://github.com/ravescovi/ORB_SLAM2.git


cd ~/workspace/
rosdep update 
rosdep install --from-paths pyrobot -i -y

cd ~/workspace/pyrobot/robots/LoCoBot/thirdparty/ORB_SLAM2
./build.sh
echo "export ORBSLAM2_LIBRARY_PATH=${ORB_SLAM2_PATH}" >> ~/.bashrc
export ORBSLAM2_LIBRARY_PATH=${ORB_SLAM2_PATH}


cd ~/workspace/
mkdir turtlebot
cd turtlebot

git clone https://github.com/turtlebot/turtlebot_simulator
git clone https://github.com/turtlebot/turtlebot.git
git clone https://github.com/turtlebot/turtlebot_apps.git
git clone https://github.com/turtlebot/turtlebot_msgs.git
git clone https://github.com/turtlebot/turtlebot_interactions.git

git clone https://github.com/toeklk/orocos-bayesian-filtering.git
cd orocos-bayesian-filtering/orocos_bfl/
./configure
make
sudo make install
cd ../
make
cd ../

git clone https://github.com/udacity/robot_pose_ekf
git clone https://github.com/ros-perception/depthimage_to_laserscan.git

git clone https://github.com/yujinrobot/kobuki_msgs.git
git clone https://github.com/yujinrobot/kobuki_desktop.git
cd kobuki_desktop/
rm -r kobuki_qtestsuite
cd ..
git clone https://github.com/yujinrobot/kobuki.git
cd kobuki && git checkout noetic && cd ..
mv kobuki/kobuki_description kobuki/kobuki_bumper2pc \
	kobuki/kobuki_node kobuki/kobuki_keyop \
	kobuki/kobuki_safety_controller ./

rm -rf kobuki

git clone https://github.com/yujinrobot/yujin_ocs.git
mv yujin_ocs/yocs_cmd_vel_mux yujin_ocs/yocs_controllers .
mv yujin_ocs/yocs_safety_controller yujin_ocs/yocs_velocity_smoother .
rm -rf yujin_ocs


##???
#sudo apt-get install ros-noetic-kobuki-* -y
#sudo apt-get install ros-noetic-ecl-streams -y



##DROIDLET Installation
# cd ~/workspace/droidlet
# pip install -r ~/workspace/droidlet/locobot/requirements.txt
# python setup.py develop 



cd ~/workspace
chmod +x pyrobot/robots/LoCoBot/locobot_navigation/orb_slam2_ros/scripts/gen_cfg.py
rosrun orb_slam2_ros gen_cfg.py
mkdir .robot
cp pyrobot/robots/LoCoBot/locobot_calibration/config/default.json .robot/



cd ~/workspace/pyrobot/robots/LoCoBot
sudo cp udev_rules/*.rules /etc/udev/rules.d
sudo service udev reload
sudo service udev restart
sudo udevadm trigger
sudo usermod -a -G dialout $USER


