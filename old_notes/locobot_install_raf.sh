LOCOBOT_FOLDER=~/low_cost_ws
if [ ! -d "$LOCOBOT_FOLDER/src" ]; then
	mkdir -p $LOCOBOT_FOLDER/src
	cd $LOCOBOT_FOLDER/src
	catkin_init_workspace
fi
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

if [ ! -d "$LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/thirdparty" ]; then

  	cd $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot
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

cd $LOCOBOT_FOLDER
rosdep update 
rosdep install --from-paths src/pyrobot -i -y
cd $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/install
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


if [ $PYTHON_VERSION == "3" ]; then
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
fi


if [ $INSTALL_TYPE == "full" ]; then
	# STEP 7 - Dependencies and config for calibration
	cd $LOCOBOT_FOLDER
	chmod +x src/pyrobot/robots/LoCoBot/locobot_navigation/orb_slam2_ros/scripts/gen_cfg.py
	rosrun orb_slam2_ros gen_cfg.py
	HIDDEN_FOLDER=~/.robot
	if [ ! -d "$HIDDEN_FOLDER" ]; then
		mkdir ~/.robot
		cp $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_calibration/config/default.json ~/.robot/
	fi
	
	# STEP 8 - Setup udev rules
	cd $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot
	sudo cp udev_rules/*.rules /etc/udev/rules.d
	sudo service udev reload
	sudo service udev restart
	sudo udevadm trigger
	sudo usermod -a -G dialout $USER
fi


end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"

echo "Installation complete, took $elapsed seconds in total"
echo "NOTE: Remember to logout and login back again before using the robot!"