from __future__ import print_function

import cv2
import numpy as np
from .core import Robot

if __name__ == "__main__":
    bot = Robot("locobot")
    rgb, depth = bot.camera.get_rgb_depth()
    cv2.imshow("Color", rgb[:, :, ::-1])
    # Multiply by 1000 just to increase contrast in depth image
    cv2.imshow("Depth", 1000* depth) 
    cv2.waitKey(5000)