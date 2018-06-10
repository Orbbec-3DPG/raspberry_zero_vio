#!/bin/bash
sleep 2s
/home/pi/vio/raspberry_zero_vio/config_uvc.sh
sleep 2s
/home/pi/vio/raspberry_zero_vio/uvc-gadget/uvc-gadget -u /dev/video1 -v /dev/video0 -w
