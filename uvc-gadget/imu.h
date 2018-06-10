#ifndef    _IMU_H_
#define   _IMU_H_
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include <poll.h>
#include <pthread.h>

#define DEFAULT_ACCEL_DEV  "iio:device0"
#define DEFAULT_GYRO_DEV   "iio:device1"
#define DEFAULT_SERIAL_DEV "ttyGS0"
#define IMU_MAX_STRING 1024
struct RawData{
    int16_t raw[3];
    uint64_t timestamp;
};

struct IMUData{
    int16_t accel[3];
    int16_t gyro[3];
    uint64_t timestamp;
    int flag;
};


struct imu_state
{
    int is_streaming;
    int is_running;
};

struct imu_device
{
    int accel_fp;
    int gyro_fp;
    int serial_fp;

    pthread_t  thread_handle;

    struct imu_state  state;

};

int imu_open(struct imu_device **p_imu);

int imu_stream_on(struct imu_device *imu);

int imu_stream_off(struct imu_device *imu);

int imu_close(struct imu_device *imu);

#endif
