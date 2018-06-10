#include "imu.h"

int main()
{
    struct imu_device *idev;
    int with_imu = 1;
    int  ret=1;
    int cnt=1000000;

    if(with_imu == 1)
    {
        ret = imu_open(&idev);
    }

    imu_stream_on(idev);


    while(1)
    {
        cnt--;
    }

    imu_stream_off(idev);


    imu_close(idev);
    return ret;
}
