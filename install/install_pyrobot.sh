#!/usr/bin/env bash

ubuntu_version="$(lsb_release -r -s)"

if [ $ubuntu_version == "18.04" ]; then
	echo "Ubuntu 18.04 detected. ROS-Melodic chosen for installation.";
	ROS_NAME="melodic"
elif [ $ubuntu_version == "20.04" ]; then
	echo "Ubuntu 20.04 detected. We'll make ROS-Noetic work."
	ROS_NAME="noetic"
	ROS_OTHER_NAME="melodic"
else
	echo -e "Unsupported Ubuntu verison: $ubuntu_version"
	echo -e "pyRobot only works with 16.04 or 18.04"
	exit 1
fi

PYROBOT_WS=~/workspace/pyrobot_ws

if [ ! -d "$PYROBOT_WS" ]; then
	sudo apt-get -y install software-properties-common
	sudo apt-get update
	sudo apt-get -y install python3-catkin-tools python3-dev python3-catkin-pkg-modules python3-numpy python3-yaml
	sudo apt-get -y install python3-tk 

	virtualenv -p /usr/bin/python3 $PYROBOT_WS
	source ~/pyrobot/bin/activate
	pip install catkin_pkg pyyaml empy rospkg
	python -m pip install --upgrade numpy
	echo "HERE" $PWD
	pip install .
	deactivate
fi

source ~/${virtualenv_name}/bin/activate
echo "Setting up PyRobot Catkin Ws..."
PYROBOT_PYTHON3_WS=~/workspace/pyrobot_catkin_ws

if [ ! -d "$PYROBOT_PYTHON3_WS/src" ]; then
	mkdir -p $PYROBOT_PYTHON3_WS/src
	cd $PYROBOT_PYTHON3_WS/src


git clone https://github.com/ros/geometry
git clone https://github.com/ros/geometry2
	# git clone -https://github.com/kalyanvasudev/vision_opencv.git

	
	git clone -b patch-1 https://github.com/kalyanvasudev/ros_comm.git

	cd ..
	
	# Install all the python 3 dependencies
	sudo apt-get -y install ros-$ROS_NAME-cv-bridge

	# Build
	#catkin_make --cmake-args -DPYTHON_EXECUTABLE=$(which python) -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so
	catkin_make --cmake-args -DPYTHON_EXECUTABLE=$(which python) -DPYTHON_INCLUDE_DIR=/usr/include/python3.8 -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.8.so -DBoost_NO_BOOST_CMAKE=OFF
	
	echo "alias load_pyrobot_env='source $VIRTUALENV_FOLDER/bin/activate && source $PYROBOT_PYTHON3_WS/devel/setup.bash'" >> ~/.bashrc
fi
deactivate
