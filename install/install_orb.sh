


cd ~/workspace

git clone https://github.com/ravescovi/ORB_SLAM2.git

ORB_SLAM2_PATH=~/workspace/ORB_SLAM2
cd $ORB_SLAM2_PATH
chmod +x build.sh
source build.sh
echo "export ORBSLAM2_LIBRARY_PATH=${ORB_SLAM2_PATH}" >> ~/.bashrc
export ORBSLAM2_LIBRARY_PATH=${ORB_SLAM2_PATH}