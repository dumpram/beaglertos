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

APP_LOAD_ADDR = 0x80000000 # LOAD IN RAM

LIB_C = /home/dumpram/ARMCompilers/gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/lib
LIB_GCC = /home/dumpram/ARMCompilers/gcc-arm-none-eabi-5_4-2016q3/lib/gcc/arm-none-eabi/5.4.1


# User source files
USER_SRC = $(wildcard src/*.c)

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
RTOS_SRC += $(wildcard $(FREERTOS_MEMMANG)/heap_1.c)

RTOS_INC := $(FREERTOS_ROOT)/include

RTOS_ASRC += $(wildcard $(FREERTOS_PORT)/*.S)

# RTOS Objects
RTOS_OBJ := $(patsubst %.c, %.o, $(RTOS_SRC))
RTOS_AOBJ := $(patsubst %.S, %.o, $(RTOS_ASRC))

# Platform libraries paths
PLATFORM_LPATH := lib/platform-am335x

PLATFORM_LIB := -lplatform \
				-lutils \
				-ldrivers \
				-lsystem_config


PLATFORM_INC := -Ilib/platform-am335x/include \
				-Ilib/platform-am335x/include/hw \
				-Ilib/platform-am335x/include/armv7a/am335x

LINKER_SCRIPT = linker.lds

# User Objects
USER_OBJ := $(patsubst %.c, %.o, $(USER_SRC))


# Compiler flags
CFLAGS := -I$(RTOS_INC) -I . -I $(FREERTOS_PORT) -I inc $(PLATFORM_INC) \
	-mcpu=cortex-a8 \
	-mfpu=neon \
	-mthumb-interwork \
	-mfloat-abi=softfp

# Linker flags
LDFLAGS := -e Entry -u Entry -u __aeabi_uidiv -u __aeabi_idiv --gc-sections


all : app

%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled "$<" successfully!"

%.o: %.S
	@$(AS) $(CFLAGS) -c $< -o $@
	@echo "Compiled "$<" successfully!"

obj/app.out : $(RTOS_OBJ) $(RTOS_AOBJ) $(USER_OBJ)
	@$(LD) $(LDFLAGS) -o $@ $(USER_OBJ) $(RTOS_OBJ) $(RTOS_AOBJ) \
	-L$(PLATFORM_LPATH) -L$(LIB_C) -L$(LIB_GCC)  \
	  -lc -lgcc $(PLATFORM_LIB) $(PLATFORM_LIB) -T$(LINKER_SCRIPT)
	@echo "Linked app successfully!"

app : obj/app.out
	@gcc -o ti_image tools/tiimage.c
	./ti_image $(APP_LOAD_ADDR) NONE obj/app.out app
	@rm ti_image
	@echo "Generated image successfully!"

clean :
	rm $(RTOS_OBJ) $(RTOS_AOBJ) $(USER_OBJ) obj/app.out
