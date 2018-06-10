CROSS_COMPILE	?= 
ARCH		?= x86
KERNEL_DIR	?= /usr/src/linux

CC		:= $(CROSS_COMPILE)gcc
KERNEL_INCLUDE	:= -I$(KERNEL_DIR)/include -I$(KERNEL_DIR)/arch/$(ARCH)/include
CFLAGS		:= -W -Wall -g $(KERNEL_INCLUDE)
LDFLAGS		:= -g -lpthread

all: uvc-gadget imu_test

uvc-gadget: uvc-gadget.o imu.c
	$(CC) $(LDFLAGS) -o $@ $^

imu_test: imu_test.o imu.c
	$(CC) $(LDFLAGS) -o $@ $^	
	
clean:
	rm -f *.o
	rm -f uvc-gadget
	rm -f imu_test
