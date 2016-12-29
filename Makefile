###############################################################################
# Makefile for BeagleBone Black FreeRTOS project
# v 1.0
# Author: Ivan Pavic
###############################################################################


# Toolchain
PREFIX = ~/ARMCompilers/gcc-arm-none-eabi-5_4-2016q3/bin/arm-none-eabi-

CC = $(PREFIX)gcc
AS = $(PREFIX)as
LD = $(PREFIX)ld

LIBC = /home/dumpram/ARMCompilers/gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/lib


# User source files
USER_SRC = src

# RTOS root
FREERTOS_ROOT = lib/FreeRTOS/Source

# RTOS platform dependent
FREERTOS_PORT = lib/FreeRTOS/Source/portable/GCC/ARM_CA9

# RTOS portable common
FREERTOS_PORT_COMMON = $(FREERTOS_ROOT)/portable/Common

# RTOS memory management
FREERTOS_MEMMANG = lib/FreeRTOS/Source/portable/MemMang

# Gathering source files
RTOS_SRC := $(wildcard $(FREERTOS_ROOT)/*.c)
RTOS_SRC += $(wildcard $(FREERTOS_PORT)/*.c)
#RTOS_SRC += $(wildcard $(FREERTOS_PORT_COMMON)/*.c)
RTOS_SRC += $(wildcard $(FREERTOS_MEMMANG)/heap_1.c)
RTOS_SRC += $(wildcard $(USER_SRC)/*.c)
RTOS_INC := $(FREERTOS_ROOT)/include

RTOS_ASRC += $(wildcard $(FREERTOS_PORT)/*.S)

# RTOS Objects
RTOS_OBJ := $(patsubst %.c, %.o, $(RTOS_SRC))
RTOS_AOBJ := $(patsubst %.S, %.o, $(RTOS_ASRC))

# Platform libraries paths
PLATFORM_LPATH := lib/platform-am335x
PLATFORM_LIB := -ldrivers \
				-lplatform \
				-lsystem_config \
				-lutils

PLATFORM_INC := -Ilib/platform-am335x/include \
				-Ilib/platform-am335x/include/hw \
				-Ilib/platform-am335x/include/armv7a/am335x

LINKER_SCRIPT = linker.lds


# Compiler flags
CFLAGS := -I$(RTOS_INC) -I . -I $(FREERTOS_PORT) -I inc $(PLATFORM_INC) \
	-mcpu=cortex-a8 \
	-mfpu=neon \
	-mthumb-interwork \
	-mfloat-abi=softfp


all : $(RTOS_OBJ) $(RTOS_AOBJ)

%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled "$<" successfully!"

%.o: %.S
	@$(AS) $(CFLAGS) -c $< -o $@
	@echo "Compiled "$<" successfully!"

app : $(RTOS_OBJ) $(RTOS_AOBJ)
	@$(LD) -L$(PLATFORM_LPATH) -L$(LIBC) -T$(LINKER_SCRIPT)  \
	 -o $@ $(RTOS_OBJ) $(RTOS_AOBJ) $(PLATFORM_LIB) -lc
	@echo "Linked app successfully!"

clean :
	rm $(RTOS_OBJ) $(RTOS_AOBJ)
