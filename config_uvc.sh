#!/bin/bash


export ACCLE_DEV=iio:device0
export GYRO_DEV=iio:device1


modprobe st_lsm6dsm_i2c
modprobe st_lsm6dsm_spi
modprobe bcm2835_v4l2
modprobe libcomposite

echo "disable the buffer"
echo 0 > /sys/bus/iio/devices/${ACCLE_DEV}/buffer/enable
echo 0 > /sys/bus/iio/devices/${GYRO_DEV}/buffer/enable


#config accel
#enable channel
echo 1 > /sys/bus/iio/devices/${ACCLE_DEV}/scan_elements/in_accel_x_en
echo 1 > /sys/bus/iio/devices/${ACCLE_DEV}/scan_elements/in_accel_y_en
echo 1 > /sys/bus/iio/devices/${ACCLE_DEV}/scan_elements/in_accel_z_en
echo 1 > /sys/bus/iio/devices/${ACCLE_DEV}/scan_elements/in_timestamp_en
#set freq
echo 208 > /sys/bus/iio/devices/${ACCLE_DEV}/sampling_frequency

#config dev
#enable channel
echo 1 > /sys/bus/iio/devices/${GYRO_DEV}/scan_elements/in_anglvel_x_en
echo 1 > /sys/bus/iio/devices/${GYRO_DEV}/scan_elements/in_anglvel_y_en
echo 1 > /sys/bus/iio/devices/${GYRO_DEV}/scan_elements/in_anglvel_z_en
echo 1 > /sys/bus/iio/devices/${GYRO_DEV}/scan_elements/in_timestamp_en
#set freq
echo 208 > /sys/bus/iio/devices/${GYRO_DEV}/sampling_frequency


mkdir -p /config
mount -t configfs none /config
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
echo "ORBBEC UVC Device" > strings/0x409/product

#2.Creating the configurations
mkdir -p configs/c.1
#Each configuration also needs its strings, so a subdirectory must be created for each language
mkdir -p configs/c.1/strings/0x409
#Then the configuration string can be specified:
echo "Conf 1" > configs/c.1/strings/0x409/configuration
#Some attributes can also be set for a configuration
echo 120 > configs/c.1/MaxPower

#3.Creating the functions
#The gadget will provide some functions, for each function its corresponding directory must be created
mkdir -p functions/uvc.usb0

cd /config/usb_gadget/g1
mkdir functions/uvc.usb0/control/header/h
cd functions/uvc.usb0/control/
ln -s header/h class/fs
ln -s header/h class/ss

cd /config/usb_gadget/g1
mkdir -p functions/uvc.usb0/streaming/uncompressed/u/480p
cd functions/uvc.usb0/streaming/uncompressed/u/480p
cat <<EOF > dwFrameInterval
333333
EOF

echo 480 > wHeight
echo 640 > wWidth
echo 614400 > dwMaxVideoFrameBufferSize
echo 147456000 > dwMaxBitRate
echo 147456000 > dwMinBitRate
#cd /config/usb_gadget/g1
#mkdir -p functions/uvc.usb0/streaming/mjpeg/m/480p
#cat <<EOF > functions/uvc.usb0/streaming/mjpeg/m/480p/dwFrameInterval
#333333
#666666
#EOF
#echo 480 > functions/uvc.usb0/streaming/mjpeg/m/480p/wHeight
#echo 640 > functions/uvc.usb0/streaming/mjpeg/m/480p/wWidth
#echo 614400 > functions/uvc.usb0/streaming/mjpeg/m/480p/dwMaxVideoFrameBufferSize


cd /config/usb_gadget/g1
mkdir -p functions/uvc.usb0/streaming/header/h
cd functions/uvc.usb0/streaming/header/h
ln -s ../../uncompressed/u
#ln -s ../../mjpeg/m
cd ../../class/fs
ln -s ../../header/h
cd ../../class/hs
ln -s ../../header/h
cd ../../class/ss
ln -s ../../header/h

cd /config/usb_gadget/g1
echo 2048 > /config/usb_gadget/g1/functions/uvc.usb0/streaming_maxpacket
echo 1   > /config/usb_gadget/g1/functions/uvc.usb0/streaming_interval
echo 0  > /config/usb_gadget/g1/functions/uvc.usb0/streaming_maxburst
#4. Associating the functions with their configurations
cd /config/usb_gadget/g1
ln -s functions/uvc.usb0 configs/c.1

cd /config/usb_gadget/g1
mkdir -p functions/acm.usb1
ln -s functions/acm.usb1 configs/c.1
#5. Enabling the gadget
ls /sys/class/udc > UDC

#6. Disabling the gadget

#7. Cleaning up




