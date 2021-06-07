

cd ~/workspace
##Check if pangolin is already installed
if ! [[ $(ldconfig -p | grep libpangolin) ]]; then
    PANGOLIN_FOLDER=~/workspace/Pangolin
    if [ ! -d "$PANGOLIN_FOLDER" ]; then
        git clone https://github.com/stevenlovegrove/Pangolin.git
    fi

	if [ ! -d "$PANGOLIN_FOLDER/build" ]; then
		cd $PANGOLIN_FOLDER
	    mkdir build
	    cd build
	    cmake ..
	    cmake --build .
	    sudo make install
	fi
else
    echo "Pangolin already exists"
fi

