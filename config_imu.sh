
export ACCLE_DEV = iio:device0
export GYRO_DEV  = iio:device1

#disable the buffer
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
echo 1 > /sys/bus/iio/devices/${GYRO_DEV}/scan_elements/in_gyro_x_en
echo 1 > /sys/bus/iio/devices/${GYRO_DEV}/scan_elements/in_gyro_y_en
echo 1 > /sys/bus/iio/devices/${GYRO_DEV}/scan_elements/in_gyro_z_en
echo 1 > /sys/bus/iio/devices/${GYRO_DEV}/scan_elements/in_timestamp_en
#set freq
echo 208 > /sys/bus/iio/devices/${GYRO_DEV}/sampling_frequency









