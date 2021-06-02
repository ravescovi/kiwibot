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
