CURR_DIR := $(shell pwd)
BUILD_DIR:=$(subst /private, /private,$(CURR_DIR))
BUILD_DIR:=$(word 1, $(BUILD_DIR))
export BUILD_DIR

include $(BUILD_DIR)/make.common

install:
	cp -af lib/  $(TOOLCHAIN_SYSROOT)

