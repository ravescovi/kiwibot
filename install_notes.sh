sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade

sudo apt-get install -y python-tk python-sip vim git terminator python3-pip python3-dev
sudo apt-get install -y screen tmux openssh-server libssl-dev libusb-1.0-0-dev libgtk-3-dev libglfw3-dev

mkdir ~/workspace
cd workspace

mkdir -p /miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash ./miniconda.sh -b -u -p ~/workspace/miniconda3
rm -rf ./miniconda.sh
./miniconda3/bin/conda init bash

##activating conda
bash

conda install pip 
conda update -n base -c defaults conda




##Installing System libs
sudo apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
sudo add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo focal main" -u
sudo apt-get update
#version="2.33.1-0~realsense0.2140"
sudo apt-get -y install librealsense2-udev-rules=${version}
sudo apt-get -y install librealsense2-dkms
sudo apt-get -y install librealsense2
sudo apt-get -y install librealsense2-gl
sudo apt-get -y install librealsense2-utils
sudo apt-get -y install librealsense2-dev
sudo apt-get -y install librealsense2-dbg
sudo apt-mark hold librealsense2*

#https://github.com/IntelRealSense/librealsense/blob/master/doc/installation.md


##downloading stuff
git clone https://github.com/facebookresearch/pyrobot.git
git clone --recursive https://github.com/facebookresearch/droidlet.git
git clone https://github.com/IntelRealSense/realsense-ros.git


export ENV=rafbot

conda create -y -n $ENV python=3.8
conda activate $ENV

conda config --env --add channels conda-forge
conda config --env --add channels robostack
conda config --env --add channels pytorch
conda config --env --set channel_priority strict

#Installing basic deps 
conda install -y numpy scipy matplotlib ipython Pillow #en-core-web-sm
conda install -y compilers cmake pkg-config make ninja catkin_tools

#and some not so basic (for droidlet)
#conda install -c conda-forge spacy-model-en_core_web_sm

#pip install -r ~/workspace/droidlet/locobot/requirements.txt
pip install bezier

##pain1
#conda install -y opencv
#conda install -y open3d

##pain2
#conda install -y pytorch torchvision

##INSTALLING ROS
## https://github.com/RoboStack/ros-noetic
#conda install -y ros-noetic-desktop ros-noetic-ddynamic-reconfigure ros-noetic-librealsense2


# 	"ros-$ROS_NAME-dynamixel-motor" 
# 	"ros-$ROS_NAME-moveit" 
# 	"ros-$ROS_NAME-trac-ik"
# 	"ros-$ROS_NAME-ar-track-alvar"
# 	"ros-$ROS_NAME-move-base"
# 	"ros-$ROS_NAME-ros-control"
# 	"ros-$ROS_NAME-gazebo-ros-control"
# 	"ros-$ROS_NAME-ros-controllers"
# 	"ros-$ROS_NAME-navigation"
# 	"ros-$ROS_NAME-rgbd-launch"
# 	"ros-$ROS_NAME-kdl-parser-py"
# 	"ros-$ROS_NAME-orocos-kdl"
# 	"ros-$ROS_NAME-python-orocos-kdl"
#   	"ros-$ROS_NAME-ddynamic-reconfigure"
# 	#"ros-$ROS_NAME-libcreate"

##this version of opencv breaks the installation but it is necessary for orb_slam2
##conda install -y -c conda-forge opencv==3.4.9

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt update

sudo apt install -y ros-noetic-desktop-full 
sudo apt install -y rospack-tools python3-rosdep python3-roslaunch 
sudo apt install -y python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
sudo apt install -y ros-noetic-rgbd-launch

source /opt/ros/noetic/setup.bash

echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
source ~/.bashrc


# conda deactivate    
# conda activate $ENV



sudo rosdep init 
rosdep update



cd ~/workspace/realsense-ros/
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

cd ~/workspace/Pangolin
conda install -c conda-forge glew
mkdir build
cd build
cmake ..
cmake --build .

cd ~/workspace/pyrobot/robots/LoCoBot/thirdparty/ORB_SLAM2
./build.sh
echo "export ORBSLAM2_LIBRARY_PATH=~/workspace/pyrobot/robots/LoCoBot/thirdparty/ORB_SLAM2" >> ~/.bashrc
export ORBSLAM2_LIBRARY_PATH=$~/workspace/pyrobot/robots/LoCoBot/thirdparty/ORB_SLAM2


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
sudo apt-get install ros-noetic-kobuki-* -y
sudo apt-get install ros-noetic-ecl-streams -y



##DROIDLET Installation
cd ~/workspace/droidlet
python setup.py develop 


sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt update

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

export ROS_PACKAGE_PATH=/home/locobot/workspace

roslaunch locobot_calibration calibrate.launch base:=kobuki