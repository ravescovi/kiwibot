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
source install_ros.sh

# Step 2: Install Realsense packages
source install_real.sh

# Step 3: Install apriltag ROS Wrapper
source install_april.sh

# Step 4: Install Locobot packages
# Step 5: Setup Environment Variables
source install_loco.sh


##TODO make this into a install 
# Install Pangolin
#source install_pang.sh

##TODO check this install 
# Install orb2 - Raf Noetic+openCV3 version
#source install_orb

##TODO check this installation
# old pyrobot installation 
#source install_low.sh

# Dynamix controller
#source install_dyna.sh




