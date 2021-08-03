#!/usr/bin/env bash




ubuntu_version="$(lsb_release -r -s)"
ROS_NAME="noetic"
ROS_OTHER_NAME="melodic"

pwd=$PWD


RAFBOT_FOLDER=~/raf_ws
if [ ! -d "$RAFBOT_FOLDER/src" ]; then
	mkdir -p $RAFBOT_FOLDER/src
	cd $RAFBOT_FOLDER/src
	catkin_init_workspace
fi

cd $RAFBOT_FOLDER/src
git clone https://github.com/facebookresearch/pyrobot.git
cd pyrobot
git checkout master
git submodule update --init --recursive
cd $RAFBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_description/urdf
ln interbotix_locobot_description.urdf locobot_description.urdf
cd $RAFBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_moveit_config/config
ln interbotix_locobot.srdf locobot.srdf
cd $RAFBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_control/src
sed -i 's/\(float restJnts\[5\] = \)\(.*\)/\1{0, -1.30, 1.617, 0.5, 0};/' locobot_controller.cpp

##change navigation CMakeFile openCV and orbslamscript

cd $RAFBOT_FOLDER/src
git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench.git
git clone https://github.com/ROBOTIS-GIT/DynamixelSDK.git
git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench-msgs.git
git clone https://github.com/ros-controls/ros_control.git
git clone https://github.com/s-gupta/ar_track_alvar.git

##hummm??
#cd ~/workspace/low_cost_ws/src/pyrobot/robots/LoCoBot/locobot_navigation
#rm -rf orb_slam2_ros
#git clone https://github.com/appliedAI-Initiative/orb_slam_2_ros.git

cd $RAFBOT_FOLDER
rosdep update 
rosdep install --from-paths src/pyrobot -i -y

catkin clean -y

if [ ! -d "$RAFBOT_FOLDER/src/turtlebot" ]; then
	cd $RAFBOT_FOLDER/src/
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
	cd kobuki && git checkout $ROS_OTHER_NAME && cd ..
	mv kobuki/kobuki_description kobuki/kobuki_bumper2pc \
	  kobuki/kobuki_node kobuki/kobuki_keyop \
	  kobuki/kobuki_safety_controller ./
	
	#rm -r kobuki

	git clone https://github.com/yujinrobot/yujin_ocs.git
	mv yujin_ocs/yocs_cmd_vel_mux yujin_ocs/yocs_controllers .
	mv yujin_ocs/yocs_safety_controller yujin_ocs/yocs_velocity_smoother .
	rm -rf yujin_ocs
fi

cd $RAFBOT_FOLDER
source /opt/ros/$ROS_NAME/setup.bash

# pip install catkin_pkg pyyaml empy rospkg
catkin_make
echo "source $RAFBOT_FOLDER/devel/setup.bash" >> ~/.bashrc
source $RAFBOT_FOLDER/devel/setup.bash



cd $RAFBOT_FOLDER
chmod +x src/pyrobot/robots/LoCoBot/locobot_navigation/orb_slam2_ros/scripts/gen_cfg.py
rosrun orb_slam2_ros gen_cfg.py
HIDDEN_FOLDER=~/.robot
if [ ! -d "$HIDDEN_FOLDER" ]; then
    mkdir ~/.robot
    cp $RAFBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_calibration/config/default.json ~/.robot/
fi

cd $RAFBOT_FOLDER/src/pyrobot/robots/LoCoBot
sudo cp udev_rules/*.rules /etc/udev/rules.d
sudo service udev reload
sudo service udev restart
sudo udevadm trigger
sudo usermod -a -G dialout $USER
    
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$RAFBOT_FOLDER/src/pyrobot

/home/locobot/workspace/low_cost_ws/src:
/home/locobot/workspace/create_ws/src/create_robot/create_bringup:
/home/locobot/workspace/create_ws/src/create_robot/create_description:
/home/locobot/workspace/create_ws/src/create_robot/create_msgs:
/home/locobot/workspace/create_ws/src/create_robot/create_robot:
/home/locobot/workspace/create_ws/src/libcreate:
/home/locobot/workspace/create_ws/src/create_robot/create_driver:
/opt/ros/noetic/share: