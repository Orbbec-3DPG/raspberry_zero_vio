#!/bin/bash

cd /config/usb_gadget/g1
echo "" > UDC

rm configs/c.1/uvc.usb0
rm configs/c.1/acm.usb1
rmdir configs/c.1/strings/0x409
rmdir configs/c.1

rm functions/uvc.usb0/streaming/header/h/u
rm functions/uvc.usb0/streaming/class/fs/h
rm functions/uvc.usb0/streaming/class/hs/h
rm functions/uvc.usb0/streaming/class/ss/h
rmdir functions/uvc.usb0/streaming/header/h

rmdir functions/uvc.usb0/streaming/uncompressed/u/480p

rmdir functions/uvc.usb0/streaming/uncompressed/u

rm functions/uvc.usb0/control/class/fs/h
rm functions/uvc.usb0/control/class/ss/h
rmdir functions/uvc.usb0/control/header/h

rmdir functions/uvc.usb0
rmdir functions/acm.usb1

rmdir strings/0x409

cd ..

rmdir g1

