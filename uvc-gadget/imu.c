#include "imu.h"
#include <pthread.h>
#include <time.h>
void *imu_read_thread(void *arg);

char iio_base[] = "/sys/bus/iio/devices/";

static int write_sysfs_int(const char *filename, const char *basedir, int val)
{
    int ret = 0;
    FILE *sysfsfp;

    char *temp = (char*)malloc(strlen(basedir) + strlen(filename) + 2);

    if (!temp)
        return -ENOMEM;

    ret = sprintf(temp, "%s/%s", basedir, filename);
    if (ret < 0)
        goto error_free;

    sysfsfp = fopen(temp, "w");
    if (!sysfsfp) {
        ret = -errno;
        fprintf(stderr, "failed to open %s\n", temp);
        goto error_free;
    }

    ret = fprintf(sysfsfp, "%d", val);
    if (ret < 0) {
        if (fclose(sysfsfp))
            perror("_write_sysfs_int(): Failed to close dir");

        goto error_free;
    }

    if (fclose(sysfsfp)) {
        ret = -errno;
        goto error_free;
    }
error_free:
    free(temp);
    return ret;
}

static int read_sysfs_int(const char *filename, const char *basedir)
{
    int ret;
    FILE  *sysfsfp;
    char *temp = (char*)malloc(strlen(basedir) + strlen(filename) + 2);

    if (!temp) {
        fprintf(stderr, "Memory allocation failed");
        return -ENOMEM;
    }

    ret = sprintf(temp, "%s/%s", basedir, filename);
    if (ret < 0)
        goto error_free;

    sysfsfp = fopen(temp, "r");
    if (!sysfsfp) {
        ret = -errno;
        goto error_free;
    }

    errno = 0;
    if (fscanf(sysfsfp, "%d\n", &ret) != 1) {
        ret = errno ? -errno : -ENODATA;
        if (fclose(sysfsfp))
            perror("read_sysfs_posint(): Failed to close dir");

        goto error_free;
    }

    if (fclose(sysfsfp))
        ret = -errno;

error_free:
    free(temp);

    return ret;
}




int imu_open(struct imu_device **p_imu)
{
    int ret = -1;
    char buf[IMU_MAX_STRING];

    struct imu_device *imu;
    imu = calloc(1, sizeof(*imu));
    if (imu == NULL) {
        ret = -ENOMEM;
        return ret;
    }
    imu_stream_off(imu);

    snprintf(buf, IMU_MAX_STRING, "%s%s", "/dev/", DEFAULT_ACCEL_DEV);
    imu->accel_fp = open(buf, O_RDONLY | O_NONBLOCK);
    if (imu->accel_fp == -1)
    {
        return -errno;
    }

    snprintf(buf, IMU_MAX_STRING, "%s%s", "/dev/", DEFAULT_GYRO_DEV);
    imu->gyro_fp = open(buf, O_RDONLY | O_NONBLOCK);
    if (imu->gyro_fp == -1)
    {
        return -errno;
    }

    snprintf(buf, IMU_MAX_STRING, "%s%s", "/dev/", DEFAULT_SERIAL_DEV);
    imu->serial_fp = open(buf, O_RDWR | O_NONBLOCK);
    if (imu->serial_fp == -1)
    {
        return -errno;
    }


    imu->state.is_running = 1;
    pthread_create(&(imu->thread_handle), NULL, imu_read_thread, imu);
    pthread_detach((imu->thread_handle));
    *p_imu = imu;
    return 0;
}

int imu_close(struct imu_device *imu)
{

    imu->state.is_running = 0;
    imu_stream_off(imu);

    //wait close the read thread
    pthread_join((imu->thread_handle),NULL);

    close(imu->serial_fp);
    close(imu->gyro_fp);
    close(imu->accel_fp);

    free(imu);
    return 0;
}

int imu_stream_on(struct imu_device *imu)
{
    char buf[IMU_MAX_STRING];
    int ret=-1;
    if (imu->state.is_streaming == 1)
    {
        return 0;
    }

    snprintf(buf, IMU_MAX_STRING, "%s%s%s", iio_base, DEFAULT_ACCEL_DEV, "/buffer");
    ret = write_sysfs_int("enable", buf, 1);
    if (ret < 0)
    {
        printf("Failed to enable imu stream\n");
        return -1;
    }
    snprintf(buf, IMU_MAX_STRING, "%s%s%s", iio_base, DEFAULT_GYRO_DEV, "/buffer");
    ret = write_sysfs_int("enable", buf, 1);
    if (ret < 0)
    {
        printf("Failed to enable imu stream\n");
        return -1;
    }
    imu->state.is_streaming = 1;

    return 0;
}

int imu_stream_off(struct imu_device *imu)
{
    char buf[IMU_MAX_STRING];
    int ret=-1;
    //disable the devicc buffer

    snprintf(buf, IMU_MAX_STRING, "%s%s%s", iio_base, DEFAULT_ACCEL_DEV, "/buffer");
    ret = write_sysfs_int("enable", buf, 0);
    if (ret < 0)
    {
        printf("Failed to enable imu stream\n");
        return -1;
    }
    snprintf(buf, IMU_MAX_STRING, "%s%s%s", iio_base, DEFAULT_GYRO_DEV, "/buffer");
    ret = write_sysfs_int("enable", buf,0);
    if (ret < 0)
    {
        printf("Failed to enable imu stream\n");
        return -1;
    }
    imu->state.is_streaming = 0;
    return 0;
}

void *imu_read_thread(void *arg)
{

    int ret = -1;
    char send_buf[IMU_MAX_STRING];
    struct RawData data;
    struct IMUData imudata;
    struct imu_device *imu = (struct imu_device *)arg;

    struct pollfd pfds[2] = {
        {
            .fd = imu->accel_fp,
            .events = POLLIN,
        },
           {
               .fd = imu->gyro_fp,
               .events = POLLIN,
           }
    };

    while (imu->state.is_running == 1)
    {
        if (imu->state.is_streaming == 1)
        {
            //poll the data
            ret = poll(pfds, 2, -1);
            if (ret < 0) {
                goto clear;
            }
            else if (ret == 0) {
                continue;
            }

            for (int i = 0; i < 2; i++)
            {

                if (pfds[i].revents)
                {
                    memset(&data, 0, sizeof(data));
                    int real_read = read(pfds[i].fd, &data, sizeof(data));
                    if (real_read < 0)
                    {
                        goto clear;
                    }
                    if (i == 0)
                    {
                        for (int i = 0; i < 3; i++)
                        {
                            imudata.accel[i] = data.raw[i];
                        }
                        if (data.timestamp == imudata.timestamp)
                        {
                            imudata.flag = 1;
                        }
                        else
                        {
                            imudata.flag = 0;
                            imudata.timestamp = data.timestamp;
                        }
                    }
                    else if (i == 1)
                    {
                        for (int i = 0; i < 3; i++)
                        {
                            imudata.gyro[i] = data.raw[i];
                        }
                        if (data.timestamp == imudata.timestamp)
                        {
                            imudata.flag = 1;
                        }
                        else
                        {
                            imudata.flag = 0;
                            imudata.timestamp = data.timestamp;
                        }
                    }

                    if (imudata.flag == 1)
                    {
                        snprintf(send_buf, IMU_MAX_STRING, "%lld %d %d %d %d %d %d\n", imudata.timestamp, imudata.accel[0], imudata.accel[1], imudata.accel[2],
                            imudata.gyro[0], imudata.gyro[1], imudata.gyro[2]);
                        write(imu->serial_fp, send_buf, strlen(send_buf));
                        memset(send_buf, 0, IMU_MAX_STRING);
                        imudata.flag = 0;
                    }

                }
            }
        }//end imu->state.is_streaming == 1
        else
        {
            //sleep

        }
    }//end imu->state.is_running == 1
clear:
    imu->state.is_streaming = 0;
    imu->state.is_running = 2;
    return NULL;

}
