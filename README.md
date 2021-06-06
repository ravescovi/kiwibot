# KiwiBot Endeavours at GLabs.


## Installation 

    git clone https://github.com/ravescovi/kiwibot
    cd kiwibot
    bash install/install_full.sh

To install the Kiwibot rosmodule run

    bash install/install_kiwi.sh

The module will be installed in `~/workspace/kiwibot_ws` you can then update the definitions directly on the module

To re-define kiwibot definitions (for testing):

    cd ~/workspace/kiwibot_ws
    ## change files you want to update
    rosdep install --from-paths src --ignore-src -r -y
    catkin_make

## Usage

- roslaunch kiwibot kiwibot_control.launch


Original notes can be found at:
https://github.com/Interbotix/interbotix_ros_rovers/tree/main/interbotix_ros_xslocobots
