#!/bin/bash

modprobe libcomposite
mkdir -p /config
mount -t configfs none /config

#####################################
mkdir -p /config/usb_gadget/g1

cd /config/usb_gadget/g1
#Each gadget needs to have its vendor id <VID> and product id <PID> specified:
echo 0x2bc5 > idVendor
echo 0x0f01 > idProduct
echo 0x0200 > bcdUSB

#A gadget also needs its serial number, manufacturer and product strings.
mkdir -p strings/0x409
echo 012345678ABCDE > strings/0x409/serialnumber
echo ORBBEC > strings/0x409/manufacturer
echo "ORBBEC RD UVC Device" > strings/0x409/product


#2.Creating the configurations
mkdir -p configs/c.1
#Each configuration also needs its strings, so a subdirectory must be created for each language
mkdir -p configs/c.1/strings/0x409
#Then the configuration string can be specified:
echo "Conf 1" > configs/c.1/strings/0x409/configuration
#Some attributes can also be set for a configuration
echo 120 > configs/c.1/MaxPower




cd /config/usb_gadget/g1
mkdir -p functions/acm.usb0
ln -s functions/acm.usb0 configs/c.1




#####################################
#5. Enabling the gadget
ls /sys/class/udc > UDC

#6. Disabling the gadget

#7. Cleaning up




