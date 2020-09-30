#
# In most cases, you only need to modify this first section.
#

all: install

CURR_DIR := $(shell pwd)
BUILD_DIR:=$(subst /binutils, /binutils,$(CURR_DIR))
BUILD_DIR:=$(word 1, $(BUILD_DIR))
export BUILD_DIR

include $(BUILD_DIR)/make.common

APP=binutils
VERS=2.32
FILE = $(APP)-$(VERS).tar.xz
LOC=https://ftp.gnu.org/gnu/binutils/

CONFIGURE_ARGS := \
	--prefix=$(TOOLCHAIN) \
	--build=$(BUILD_HOST) --host=$(BUILD_HOST) --target=$(TOOLCHAIN_PREFIX) \
	--with-sysroot=$(TOOLCHAIN_SYSROOT) \
	--with-abi=$(TARGET_ABI) --with-arch=$(TARGET_MIPS_ARCH) \
	--disable-decimal-float --with-float=$(TARGET_FLOAT) \
	--disable-multilib --disable-nls --disable-debug \
	--enable-threads --enable-tls --enable-shared \
	--disable-libquadmath --disable-libsanitizer --disable-libgomp --disable-libssp \
	--enable-target-optspace --enable-plugins --enable-lto \
	--with-lib-path=$(TOOLCHAIN_SYSROOT)/usr/lib:$(TOOLCHAIN_SYSROOT)/lib

SOURCE_ID_FILE = $(CURR_DIR)/$(APP)-SOURCE_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)
CONFIG_ID_FILE = $(CURR_DIR)/$(APP)-CONFIG_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)
COMPILE_ID_FILE = $(CURR_DIR)/$(APP)-COMPILE_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)

.PHONY: install clean distclean shell

$(BUILD_HOST_DL)/$(FILE) :
	wget -O $(BUILD_HOST_DL)/$(FILE) $(LOC)/$(FILE)

$(SOURCE_ID_FILE) : $(BUILD_HOST_DL)/$(FILE)
	@mkdir -p $(APP)
	(tar -C $(APP) --strip-components=1 -xkf $(BUILD_HOST_DL)/$(FILE) 1>$(SOURCE_ID_FILE) 2>&1 || true)
	@echo "$(APP) is untarred"

$(CONFIG_ID_FILE) : $(SOURCE_ID_FILE)
	@mkdir -p build-$(APP)
	@cd build-$(APP); ../$(APP)/configure $(CONFIGURE_ARGS) 1>$(CONFIG_ID_FILE) 2>&1
	@echo "$(APP) is configured"

$(COMPILE_ID_FILE) : $(CONFIG_ID_FILE)
	$(MAKE) -C build-$(APP) 1>$(COMPILE_ID_FILE) 2>&1

install : $(COMPILE_ID_FILE)
	$(MAKE) -C build-$(APP) install-strip
	$(MAKE) -C build-$(APP) check

clean:
	rm -rf build-$(APP) $(COMPILE_ID_FILE) $(CONFIG_ID_FILE)

distclean:
	rm -rf $(APP) build-$(APP) $(APP)-*_ID_*

# Shell target permits creating an interacive shell for debugging
shell:
	bash -i


