#
# In most cases, you only need to modify this first section.
#

all: build

CURR_DIR := $(shell pwd)
BUILD_DIR:=$(subst /kernel, /kernel,$(CURR_DIR))
BUILD_DIR:=$(word 1, $(BUILD_DIR))
export BUILD_DIR

include $(BUILD_DIR)/make.common

APP=linux-2.6.36.x
LOC=https://github.com/protectivedad/G902_Kernel.git

CONFIGURE_ARGS := \
	ARCH=$(TARGET_ARCH) \
	INSTALL_HDR_PATH=$(LINUX_HEADERS)

SOURCE_ID_FILE = $(CURR_DIR)/$(APP)-SOURCE_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)

.PHONY: headers clean distclean shell

$(SOURCE_ID_FILE) :
	git clone --depth=1 $(LOC) $(APP) 1>$(SOURCE_ID_FILE) 2>&1
	@echo "$(APP) is pulled"

headers : $(SOURCE_ID_FILE)
	$(MAKE) -C $(APP) $(CONFIGURE_ARGS) headers_install
	rm `find $(TOOLCHAIN_SYSROOT) -name .install`
	rm `find $(TOOLCHAIN_SYSROOT) -name ..install.cmd`

clean:

distclean:
	rm -rf $(APP) $(APP)-*_ID_*

# Shell target permits creating an interacive shell for debugging
shell:
	bash -i


