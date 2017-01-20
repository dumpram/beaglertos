###############################################################################
# Makefile for BeagleBone Black FreeRTOS project
# v 1.0
# Author: Ivan Pavic
###############################################################################


# Toolchain
TOOLCHAIN_ROOT = /home/dumpram/ARMCompilers/gcc-arm-none-eabi-5_4-2016q3

PREFIX = ~/ARMCompilers/gcc-arm-none-eabi-5_4-2016q3/bin/arm-none-eabi-

CC = $(PREFIX)gcc
AS = $(PREFIX)gcc
LD = $(PREFIX)ld
AR = $(PREFIX)ar
BIN = $(PREFIX)objcopy

APP_LOAD_ADDR = 0x80000000 # LOAD IN RAM

LIB_C = $(TOOLCHAIN_ROOT)/arm-none-eabi/lib
LIB_GCC = $(TOOLCHAIN_ROOT)/lib/gcc/arm-none-eabi/5.4.1

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

LIBSYSTEM_CONFIG := lib/platform-am335x/libsystem_config.a
SYSCONFIG_SRC := lib/platform-am335x/system_config/armv7a
COMPILER := gcc
DEVICE := am335x
ARFLAGS := -c -r

LIBSYSTEM_CONFIG_SRC := ${SYSCONFIG_SRC}/mmu.c \
	${SYSCONFIG_SRC}/cache.c               \
	${SYSCONFIG_SRC}/${COMPILER}/cpu.c     \
	${SYSCONFIG_SRC}/${DEVICE}/interrupt.c \
	${SYSCONFIG_SRC}/${DEVICE}/startup.c   \
	${SYSCONFIG_SRC}/${DEVICE}/clock.c     \
    ${SYSCONFIG_SRC}/${DEVICE}/device.c    \

LIBSYSTEM_CONFIG_ASRC := ${SYSCONFIG_SRC}/${COMPILER}/cp15.S    \
	${SYSCONFIG_SRC}/${COMPILER}/init.S    \
	${SYSCONFIG_SRC}/${DEVICE}/${COMPILER}/exceptionhandler.S

LIBSYSTEM_CONFIG_OBJ := $(patsubst %.c, %.o, $(LIBSYSTEM_CONFIG_SRC))
LIBSYSTEM_CONFIG_OBJ += $(patsubst %.S, %.o, $(LIBSYSTEM_CONFIG_ASRC))

PLATFORM_LIB := -lplatform \
				-lutils \
				-ldrivers \
				-lsystem_config


PLATFORM_INC := -Ilib/platform-am335x/include \
				-Ilib/platform-am335x/include/hw \
				-Ilib/platform-am335x/include/armv7a \
				-Ilib/platform-am335x/include/armv7a/am335x

LINKER_SCRIPT = linker.lds

BINFLAGS = -O binary

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


# Export path on SD card
EXPORT := /media/dumpram/BOOT

all : app

%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled "$<" successfully!"

%.o: %.S
	@$(AS) $(CFLAGS) -c $< -o $@
	@echo "Compiled "$<" successfully!"

obj/app.out : $(LIBSYSTEM_CONFIG) $(RTOS_OBJ) $(RTOS_AOBJ) $(USER_OBJ)
	@$(LD) $(LDFLAGS) -o $@ $(USER_OBJ) $(RTOS_OBJ) $(RTOS_AOBJ) \
	-L$(PLATFORM_LPATH) -L$(LIB_C) -L$(LIB_GCC)  \
	  -lc -lgcc $(PLATFORM_LIB) $(PLATFORM_LIB) -T$(LINKER_SCRIPT)
	@echo "Linked app successfully!"

app : obj/app.out
	@gcc -o ti_image tools/tiimage.c
	@$(BIN) $(BINFLAGS) obj/app.out obj/app.bin
	./ti_image $(APP_LOAD_ADDR) NONE obj/app.bin app
	@rm ti_image
	@echo "Generated image successfully!"

$(LIBSYSTEM_CONFIG) : $(LIBSYSTEM_CONFIG_OBJ)
	@$(AR) $(ARFLAGS) $@ $(LIBSYSTEM_CONFIG_OBJ)
	@echo "Created system_config library successfully!"

clean :
	rm -f $(LIBSYSTEM_CONFIG_OBJ) $(RTOS_OBJ) $(RTOS_AOBJ) $(USER_OBJ) \
	obj/app.out app

export: app
	cp app $(EXPORT)/app
	sync
	@echo "App exported successfully!"
