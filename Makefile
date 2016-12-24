###############################################################################
# Makefile for BeagleBone Black FreeRTOS project
# v 1.0
# Author: Ivan Pavic
###############################################################################


# Toolchain
PREFIX = ~/ARMCompilers/gcc-arm-none-eabi-5_4-2016q3/bin/arm-none-eabi-

CC = $(PREFIX)gcc
AS = $(PREFIX)as

# User source files
USER_SRC = src

# RTOS root
FREERTOS_ROOT = lib/FreeRTOS/Source

# RTOS platform dependent
FREERTOS_PORT = lib/FreeRTOS/Source/portable/GCC/ARM_CA9

# RTOS memory management
FREERTOS_MEMMANG = lib/FreeRTOS/Source/portable/MemMang

# Gathering source files
RTOS_SRC := $(wildcard $(FREERTOS_ROOT)/*.c)
RTOS_SRC += $(wildcard $(FREERTOS_PORT)/*.c)
RTOS_SRC += $(wildcard $(FREERTOS_MEMMANG)/heap_1.c)
RTOS_SRC += $(wildcard $(USER_SRC)/platform.c)
RTOS_INC := $(FREERTOS_ROOT)/include

RTOS_ASRC += $(wildcard $(FREERTOS_PORT)/*.S)

# RTOS Objects
RTOS_OBJ := $(patsubst %.c, %.o, $(RTOS_SRC))
RTOS_AOBJ := $(patsubst %.S, %.o, $(RTOS_ASRC))

# Compiler flags
CFLAGS := -I$(RTOS_INC) -I . -I $(FREERTOS_PORT) \
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

test :
	@echo $(RTOS_OBJ)

clean :
	rm $(RTOS_OBJ) $(RTOS_AOBJ)