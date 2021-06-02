#!/usr/bin/env bash
ubuntu_version="$(lsb_release -r -s)"

if [ $ubuntu_version == "16.04" ]; then
  ROS_NAME="kinetic"
elif [ $ubuntu_version == "18.04" ]; then
  ROS_NAME="melodic"
elif [ $ubuntu_version == "20.04" ]; then
  ROS_NAME="noetic"
else
  echo -e "Unsupported Ubuntu verison: $ubuntu_version"
  echo -e "Interbotix Locobot only works with 16.04, 18.04, or 20.04"
  exit 1
fi

echo "Ubuntu $ubuntu_version detected. ROS-$ROS_NAME chosen for installation.";

echo -e "\e[1;33m ******************************************** \e[0m"
echo -e "\e[1;33m The installation may take around 15 Minutes! \e[0m"
echo -e "\e[1;33m ******************************************** \e[0m"
sleep 4
start_time="$(date -u +%s)"

# Update the system
sudo apt update && sudo apt -y upgrade
sudo apt -y autoremove

# Install some necessary core packages
sudo apt -y install openssh-server
if [ $ROS_NAME != "noetic" ]; then
  sudo apt -y install python-pip
  sudo -H pip install modern_robotics
else
  sudo apt -y install python3-pip
  sudo -H pip3 install modern_robotics
fi

# Step 1: Install ROS
if [ $(dpkg-query -W -f='${Status}' ros-$ROS_NAME-desktop-full 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo "Installing ROS..."
  sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
  sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
  sudo apt update
  sudo apt -y install ros-$ROS_NAME-desktop-full
  if [ -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
  fi
  echo "source /opt/ros/$ROS_NAME/setup.bash" >> ~/.bashrc
  if [ $ROS_NAME != "noetic" ]; then
    sudo apt -y install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
  else
    sudo apt -y install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
  fi
  sudo rosdep init
  rosdep update
else
  echo "ros-$ROS_NAME-desktop-full is already installed!"
fi
source /opt/ros/$ROS_NAME/setup.bash

# Step 2: Install Realsense packages

# Step 2A: Install librealsense2
if [ $(dpkg-query -W -f='${Status}' librealsense2 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo "Installing librealsense2..."

  # https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_linux.md  
  sudo apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
  sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -sc) main" -u
  # sudo add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo $(lsb_release -sc) main" -u
  if [ $ubuntu_version == "16.04" ]; then
    version="2.40.0-0~realsense0.3813"
  elif [ $ubuntu_version == "18.04" ]; then
    version="2.40.0-0~realsense0.3814"
  elif [ $ubuntu_version == "20.04" ]; then
    version="2.45.0-0~realsense0.4552"
    # version="2.40.0-0~realsense0.3815"
  fi

  sudo apt -y install librealsense2-udev-rules=${version}
  sudo apt -y install librealsense2-dkms
  sudo apt -y install librealsense2=${version}
  sudo apt -y install librealsense2-gl=${version}
  sudo apt -y install librealsense2-gl-dev=${version}
  sudo apt -y install librealsense2-gl-dbg=${version}
  sudo apt -y install librealsense2-net=${version}
  sudo apt -y install librealsense2-net-dev=${version}
  sudo apt -y install librealsense2-net-dbg=${version}
  sudo apt -y install librealsense2-utils=${version}
  sudo apt -y install librealsense2-dev=${version}
  sudo apt -y install librealsense2-dbg=${version}
  sudo apt-mark hold librealsense2*
  sudo apt -y install ros-$ROS_NAME-ddynamic-reconfigure
else
  echo "librealsense2 already installed!"
fi

# Step 2B: Install realsense2 ROS Wrapper
REALSENSE_WS=~/workspace/realsense_ws
if [ ! -d "$REALSENSE_WS/src" ]; then
  echo "Installing RealSense ROS Wrapper..."
  mkdir -p $REALSENSE_WS/src
  cd $REALSENSE_WS/src
  git clone https://github.com/IntelRealSense/realsense-ros.git
  cd realsense-ros/
  git checkout 2.2.20
  cd $REALSENSE_WS
  catkin_make clean
  catkin_make -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release
  catkin_make install
  echo "source $REALSENSE_WS/devel/setup.bash" >> ~/.bashrc
else
  echo "RealSense ROS Wrapper already installed!"
fi
source $REALSENSE_WS/devel/setup.bash

# Step 3: Install apriltag ROS Wrapper
APRILTAG_WS=~/workspace/apriltag_ws
if [ ! -d "$APRILTAG_WS/src" ]; then
  echo "Installing Apriltag ROS Wrapper..."
  mkdir -p $APRILTAG_WS/src
  cd $APRILTAG_WS/src
  git clone https://github.com/AprilRobotics/apriltag.git
  git clone https://github.com/AprilRobotics/apriltag_ros.git
  cd $APRILTAG_WS
  rosdep install --from-paths src --ignore-src -r -y
  catkin_make_isolated
  echo "source $APRILTAG_WS/devel_isolated/setup.bash" >> ~/.bashrc
else
  echo "Apriltag ROS Wrapper already installed!"
fi
source $APRILTAG_WS/devel_isolated/setup.bash

# Step 4: Install Locobot packages
shopt -s extglob
INTERBOTIX_WS=~/workspace/interbotix_ws
if [ ! -d "$INTERBOTIX_WS/src" ]; then
  echo "Installing ROS packages for the Interbotix Locobot..."
  mkdir -p $INTERBOTIX_WS/src
  cd $INTERBOTIX_WS/src
  if [ $ROS_NAME != "kinetic" ]; then
    echo "Building Kobuki ROS packages from source..."
    git clone https://github.com/yujinrobot/kobuki
    cd kobuki
    # there is no noetic branch yet, so if using noetic, clone the melodic branch
    git checkout melodic
    cd ..
    if [ $ROS_NAME == "noetic" ]; then
      sudo apt -y install liborocos-kdl-dev
      git clone https://github.com/yujinrobot/yujin_ocs.git
      cd yujin_ocs
      sudo rm -r !(yocs_cmd_vel_mux|yocs_controllers|yocs_velocity_smoother)
      cd ..
      git clone https://github.com/Slamtec/rplidar_ros.git
    fi
  fi
  git clone https://github.com/Interbotix/interbotix_ros_core.git
  git clone https://github.com/Interbotix/interbotix_ros_rovers.git
  git clone https://github.com/Interbotix/interbotix_ros_toolboxes.git
  cd interbotix_ros_rovers && git checkout $ROS_NAME && cd ..
  rm interbotix_ros_core/interbotix_ros_xseries/CATKIN_IGNORE
  rm interbotix_ros_toolboxes/interbotix_xs_toolbox/CATKIN_IGNORE
  rm interbotix_ros_toolboxes/interbotix_perception_toolbox/CATKIN_IGNORE
  rm interbotix_ros_toolboxes/interbotix_common_toolbox/interbotix_moveit_interface/CATKIN_IGNORE
  cd interbotix_ros_core/interbotix_ros_xseries/interbotix_xs_sdk
  sudo cp 99-interbotix-udev.rules /etc/udev/rules.d/
  sudo udevadm control --reload-rules && sudo udevadm trigger
  cd $INTERBOTIX_WS
  rosdep install --from-paths src --ignore-src -r -y
  catkin_make
  echo "source $INTERBOTIX_WS/devel/setup.bash" >> ~/.bashrc
else
  echo "Interbotix Locobot ROS packages already installed!"
fi
source $INTERBOTIX_WS/devel/setup.bash
shopt -u extglob

# Step 5: Setup Environment Variables
if [ -z "$ROS_IP" ]; then
  echo "Setting up Environment Variables..."
  echo 'export ROS_IP=$(echo `hostname -I | cut -d" " -f1`)' >> ~/.bashrc
  echo -e 'if [ -z "$ROS_IP" ]; then\n\texport ROS_IP=127.0.0.1\nfi' >> ~/.bashrc
else
  echo "Environment variables already set!"
fi

end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"

echo "Installation complete, took $elapsed seconds in total"
echo "NOTE: Remember to reboot the computer before using the robot!"



LOCOBOT_FOLDER=~/workspace/low_cost_ws
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
  git clone https://github.com/s-gupta/ar_track_alvar.git
  git clone https://github.com/ravescovi/ORB_SLAM2.git

		cd create_autonomy && git checkout 90e597ea4d85cde1ec32a1d43ea2dd0b4cbf481c && cd ..
		cd dynamixel-workbench && git checkout bf60cf8f17e8385f623cbe72236938b5950d3b56 && cd ..
		cd DynamixelSDK && git checkout 05dcc5c551598b4d323bf1fb4b9d1ee03ad1dfd9 && cd ..
		cd dynamixel-workbench-msgs && git checkout 93856f5d3926e4d7a63055c04a3671872799cc86 && cd ..
		cd ros_control && git checkout cd39acfdb2d08dc218d04ff98856b0e6a525e702 && cd ..
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
fi


#######################################################################################################
#######################################################################################################
# ONLY TESTED HERE!!



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


export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:~/low_cost_ws/src/pyrobot

