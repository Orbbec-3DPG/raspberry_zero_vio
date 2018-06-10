#!/bin/bash
sleep 1s
/home/pi/vio/raspberry_zero_vio/config_imu.sh
sleep 1s
/home/pi/vio/raspberry_zero_vio/config_uvc.sh
sleep 2s
/home/pi/vio/raspberry_zero_vio/uvc-gadget/uvc-gadget -u /dev/video1 -v /dev/video0 -w
