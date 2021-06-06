#!/usr/bin/env bash



shopt -s extglob
KIWI_WS=~/workspace/kiwibot_ws

rm -rf $KIWI_WS
mkdir -p $KIWI_WS/src


cd $KIWI_WS/src
git clone https://github.com/ravescovi/kiwibot

cd $KIWI_WS
rosdep install --from-paths src --ignore-src -r -y
catkin_make
echo "source $KIWI_WS/devel/setup.bash" >> ~/.bashrc

source $KIWI_WS/devel/setup.bash
shopt -u extglob

