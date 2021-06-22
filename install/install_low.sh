#!/usr/bin/env bash
ubuntu_version="$(lsb_release -r -s)"

if [ $ubuntu_version == "16.04" ]; then
  ROS_NAME="kinetic"
elif [ $ubuntu_version == "18.04" ]; then
  ROS_NAME="melodic"
elif [ $ubuntu_version == "20.04" ]; then
  ROS_NAME="noetic"
  ROS_OTHER_NAME="melodic"
else
  echo -e "Unsupported Ubuntu verison: $ubuntu_version"
  echo -e "Interbotix Locobot only works with 16.04, 18.04, or 20.04"
  exit 1
fi

pwd=$PWD


##creates the catkin workspace
LOCOBOT_FOLDER=~/workspace/low_cost_ws
if [ ! -d "$LOCOBOT_FOLDER/src" ]; then
	mkdir -p $LOCOBOT_FOLDER/src
	cd $LOCOBOT_FOLDER/src
	catkin_init_workspace
fi

##sets up the pyrobot facebook env
if [ ! -d "$LOCOBOT_FOLDER/src/pyrobot" ]; then
  cd $LOCOBOT_FOLDER/src
  git clone https://github.com/facebookresearch/pyrobot.git
  cd pyrobot
  git checkout master
  git submodule update --init --recursive
  cd $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_description/urdf
  ln interbotix_locobot_description.urdf locobot_description.urdf
  cd $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_moveit_config/config
  ln interbotix_locobot.srdf locobot.srdf
  cd $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_control/src
  sed -i 's/\(float restJnts\[5\] = \)\(.*\)/\1{0, -1.30, 1.617, 0.5, 0};/' locobot_controller.cpp
fi

##downloads all third party things 
if [ ! -d "$LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/thirdparty" ]; then
	cd $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot
	mkdir thirdparty
	cd thirdparty
#	git clone https://github.com/AutonomyLab/create_autonomy
	git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench.git
	git clone https://github.com/ROBOTIS-GIT/DynamixelSDK.git
	git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench-msgs.git
	git clone https://github.com/ros-controls/ros_control.git
#	git clone https://github.com/s-gupta/ar_track_alvar.git


fi

##hummm??
#cd ~/workspace/low_cost_ws/src/pyrobot/robots/LoCoBot/locobot_navigation
#rm -rf orb_slam2_ros
#git clone https://github.com/appliedAI-Initiative/orb_slam_2_ros.git

cd $LOCOBOT_FOLDER
rosdep update 
rosdep install --from-paths src/pyrobot -i -y


cd $LOCOBOT_FOLDER
if [ -d "$LOCOBOT_FOLDER/devel" ]; then
	rm -rf $LOCOBOT_FOLDER/devel
fi
if [ -d "$LOCOBOT_FOLDER/build" ]; then
	rm -rf $LOCOBOT_FOLDER/build
fi

if [ ! -d "$LOCOBOT_FOLDER/src/turtlebot" ]; then
	cd $LOCOBOT_FOLDER/src/
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

cd $LOCOBOT_FOLDER
source /opt/ros/$ROS_NAME/setup.bash

# pip install catkin_pkg pyyaml empy rospkg
catkin_make
echo "source $LOCOBOT_FOLDER/devel/setup.bash" >> ~/.bashrc
source $LOCOBOT_FOLDER/devel/setup.bash

cd $LOCOBOT_FOLDER/src/pyrobot
chmod +x install_pyrobot.sh
source install_pyrobot.sh  -p 3

virtualenv_name="pyenv_pyrobot_python3"
cd $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot
source ~/${virtualenv_name}/bin/activate
pip3 install --ignore-installed -r requirements_python3.txt
deactivate

#######################################################################################################
#######################################################################################################
# ONLY TESTED HERE!!


if false ; then
    # Ian: Is this calibration thing?
    cd $LOCOBOT_FOLDER
    chmod +x src/pyrobot/robots/LoCoBot/locobot_navigation/orb_slam2_ros/scripts/gen_cfg.py
    rosrun orb_slam2_ros gen_cfg.py
    HIDDEN_FOLDER=~/.robot
    if [ ! -d "$HIDDEN_FOLDER" ]; then
        mkdir ~/.robot
        cp $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_calibration/config/default.json ~/.robot/
    fi

    cd $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot
    sudo cp udev_rules/*.rules /etc/udev/rules.d
    sudo service udev reload
    sudo service udev restart
    sudo udevadm trigger
    sudo usermod -a -G dialout $USER
fi
    
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$LOCOBOT_FOLDER/src/pyrobot

cd $pwd
