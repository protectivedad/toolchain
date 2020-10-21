#
# In most cases, you only need to modify this first section.
#

all: install

CURR_DIR := $(shell pwd)
BUILD_DIR:=$(subst /uclibc, /uclibc,$(CURR_DIR))
BUILD_DIR:=$(word 1, $(BUILD_DIR))
export BUILD_DIR

include $(BUILD_DIR)/make.common

APP=uClibc
LOC=git://uclibc-ng.org/git/uclibc-ng
BRANCH=v1.0.36

CONFIGURE_ARGS := \
	ARCH=$(TARGET_ARCH) \
	PREFIX=$(TOOLCHAIN_SYSROOT) \
	KERNEL_HEADERS=$(LINUX_HEADERS)/include

CONFIGURE_ARGS_1 := $(CONFIGURE_ARGS) \
	CROSS=$(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)-

CONFIGURE_ARGS_2 := $(CONFIGURE_ARGS_1) \
	UCLIBC_EXTRA_CFLAGS='-fmessage-length=0' \
	UCLIBC_EXTRA_LDFLAGS='-Wl,-O1,-s,--gc-sections,-Map=$(CURR_DIR)/uClibc.map,--cref'

SOURCE_ID_FILE = $(CURR_DIR)/$(APP)-SOURCE_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)
CONFIG_ID_FILE = $(CURR_DIR)/$(APP)-CONFIG_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)
PREGEN_ID_FILE = $(CURR_DIR)/$(APP)-PREGEN_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)

.PHONY: headers startfiles install install_utils clean distclean shell

$(SOURCE_ID_FILE) :
	-[ ! -d $(APP) ] && git clone --depth=1 --branch $(BRANCH) $(LOC) $(APP) 1>$(SOURCE_ID_FILE) 2>&1
	@echo "$(APP) is cloned" 1>>$(SOURCE_ID_FILE) 2>&1

$(CONFIG_ID_FILE) : $(SOURCE_ID_FILE)
	cp -f g902_defconfig $(APP)/extra/Configs/defconfigs/mips/ 1>$(CONFIG_ID_FILE) 2>&1
	$(MAKE) -C $(APP) g902_defconfig 1>>$(CONFIG_ID_FILE) 2>&1

$(PREGEN_ID_FILE):
	$(MAKE) -C $(APP) $(CONFIGURE_ARGS_1) pregen 1>$(PREGEN_ID_FILE) 2>&1

headers : $(CONFIG_ID_FILE)
	$(MAKE) -C $(APP) $(CONFIGURE_ARGS) install_headers
	ln -sf $(TOOLCHAIN_SYSROOT)/usr/include $(TOOLCHAIN_SYSROOT)/sys-include

# Do a pregen to generate some headers that required the compiler and then
# reinstall the headers before the second stage of the compiler build.
startfiles : $(CONFIG_ID_FILE) $(PREGEN_ID_FILE)
	$(MAKE) -C $(APP) $(CONFIGURE_ARGS_1) install_headers install_startfiles

install : $(CONFIG_ID_FILE) $(PREGEN_ID_FILE)
	$(MAKE) -C $(APP) $(CONFIGURE_ARGS_2) install

install_utils:
	$(MAKE) -C $(APP) $(CONFIGURE_ARGS_1) install_utils

install_hostutils:
	$(MAKE) -C $(APP) $(CONFIGURE_ARGS_1) install_hostutils

nconfig: $(CONFIG_ID_FILE)
	$(MAKE) -C $(APP) $(CONFIGURE_ARGS) nconfig

clean:
	git -C $(APP) clean -dXf
	rm -f $(CONFIG_ID_FILE) $(PREGEN_ID_FILE) $(CURR_DIR)/uClibc.map

distclean:
	git -C $(APP) clean -dxf
	rm -rf $(APP)-*_ID_* $(CURR_DIR)/uClibc.map

# Shell target permits creating an interacive shell for debugging
shell:
	bash -i
