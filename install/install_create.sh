


CREATE_WS=~/workspace/create_ws
if [ ! -d "$CREATE_WS/src" ]; then
  mkdir -p $CREATE_WS/src
  cd $CREATE_WS/src
  git clone https://github.com/AutonomyLab/libcreate.git
  git clone https://github.com/autonomylab/create_robot.git
  catkin build
  echo "source $CREATE_WS/devel/setup.bash" >> ~/.bashrc
else
  echo "Libcreate ROS Wrapper already installed!"
fi
source $CREATE_WS/devel/setup.bash
