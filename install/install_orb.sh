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

LOCOBOT_FOLDER=~/workspace/low_cost_ws

chmod +x $LOCOBOT_FOLDER/src/pyrobot/robots/LoCoBot/locobot_navigation/orb_slam2_ros/scripts/gen_cfg.py
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
cd -

export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:~/low_cost_ws/src/pyrobot

