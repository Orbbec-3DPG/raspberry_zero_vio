#!/bin/bash
sleep 2s
/home/pi/usb_gadget/config_uvc.sh
sleep 2s
/home/pi/usb_gadget/uvc-gadget/uvc-gadget -u /dev/video1 -v /dev/video0
