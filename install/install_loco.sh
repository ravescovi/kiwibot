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


# Update the system
sudo apt update && sudo apt -y upgrade
sudo apt -y autoremove

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
