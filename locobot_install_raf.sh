
#sudo pip install --upgrade cryptography
#sudo python -m easy_install --upgrade pyOpenSSL
#sudo pip install --upgrade pip==20.3


#echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc

#source /opt/ros/$ROS_NAME/setup.bash


##################################################################
## I DONT THINK I NEED THIS ON MY VERSION
# STEP 3 - Install ROS debian dependencies
# declare -a ros_package_names=(
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
# 	)

# install_packages "${ros_package_names[@]}"





# STEP 4B: Install realsense2 SDK from source (in a separate catkin workspace)

git clone https://github.com/IntelRealSense/realsense-ros.git
cd realsense-ros/
git checkout 2.3.0

make clean
make -DCMAKE_BUILD_TYPE=Release


cd ~/workspace/pyrobot/robots/LoCoBot/install

chmod +x install_orb_slam2.sh
source install_orb_slam2.sh
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
	cd -
	git clone https://github.com/yujinrobot/kobuki.git
	cd kobuki && git checkout $ROS_NAME && cd ..
	mv kobuki/kobuki_description kobuki/kobuki_bumper2pc \
	  kobuki/kobuki_node kobuki/kobuki_keyop \
	  kobuki/kobuki_safety_controller ./
	
	#rm -r kobuki

	git clone https://github.com/yujinrobot/yujin_ocs.git
	mv yujin_ocs/yocs_cmd_vel_mux yujin_ocs/yocs_controllers .
	mv yujin_ocs/yocs_safety_controller yujin_ocs/yocs_velocity_smoother .
	rm -rf yujin_ocs

	sudo apt-get install ros-$ROS_NAME-kobuki-* -y
	sudo apt-get install ros-$ROS_NAME-ecl-streams -y
fi


### 6 
cd $LOCOBOT_FOLDER
source /opt/ros/$ROS_NAME/setup.bash
if [ $INSTALL_TYPE == "full" ]; then
            source $CAMERA_FOLDER/devel/setup.bash
fi
pip install catkin_pkg pyyaml empy rospkg
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




# STEP 7 - Dependencies and config for calibration
cd $LOCOBOT_FOLDER
chmod +x src/pyrobot/robots/LoCoBot/locobot_navigation/orb_slam2_ros/scripts/gen_cfg.py
rosrun orb_slam2_ros gen_cfg.py
HIDDEN_FOLDER=~/.robot
if [ ! -d "$HIDDEN_FOLDER" ]; then
    mkdir ~/.robot
    cp $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_calibration/config/default.json ~/.robot/
fi

