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

pwd=$PWD

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

cd $pwd
