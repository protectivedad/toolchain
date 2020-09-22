#
# In most cases, you only need to modify this first section.
#

all: install

CURR_DIR := $(shell pwd)
BUILD_DIR:=$(subst /gcc, /gcc,$(CURR_DIR))
BUILD_DIR:=$(word 1, $(BUILD_DIR))
export BUILD_DIR

include $(BUILD_DIR)/make.common

APP=$(COMPILER_NAME)
VERS=$(COMPILER_VERS)
BRANCH = $(APP)-$(VERS)
LOC=git://gcc.gnu.org/git/gcc.git

GMP=gmp-6.1.1
GMP_FILE=$(GMP).tar.xz
GMP_LOC=https://ftp.gnu.org/gnu/gmp
MPFR=mpfr-3.1.5
MPFR_FILE=$(MPFR).tar.xz
MPFR_PATCH=allpatches
MPFR_LOC=https://www.mpfr.org/mpfr-current/
MPC=mpc-1.0.3
MPC_FILE=$(MPC).tar.gz
MPC_LOC=https://ftp.gnu.org/gnu/mpc
ISL=isl-0.14.1
ISL_FILE=$(ISL).tar.xz
ISL_LOC=http://isl.gforge.inria.fr

GCCADDS=$(GMP) $(MPFR) $(MPC) $(ISL)

LIBC_SO=$(TOOLCHAIN_SYSROOT)/usr/lib/libc.so

CONFIGURE_ARGS := \
	--prefix=$(TOOLCHAIN) \
	--build=$(BUILD_HOST) --host=$(BUILD_HOST) --target=$(TOOLCHAIN_PREFIX) \
	--with-sysroot=$(TOOLCHAIN_SYSROOT) \
	--with-abi=$(TARGET_ABI) --with-arch=$(TARGET_MIPS_ARCH) \
	--disable-decimal-float --with-float=$(TARGET_FLOAT) \
	--disable-multilib --disable-nls --disable-debug \
	--enable-threads --enable-tls --enable-shared \
	--disable-libquadmath --disable-libsanitizer --disable-libgomp --disable-libssp \
	--enable-target-optspace --enable-lto \
	--with-build-time-tools=$(TOOLCHAIN_SYSROOT)/bin \
	--enable-long-long --enable-c99 \
	--enable-languages=c,c++ \
	--enable-version-specific-runtime-libs

MAKE_OPTS := \
	gcc_cv_libc_provides_ssp=no


GIT_ID_FILE = $(CURR_DIR)/$(APP)-GIT_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)
SOURCE_ID_FILE = $(CURR_DIR)/$(APP)-SOURCE_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)
PATCH_ID_FILE = $(CURR_DIR)/$(APP)-PATCH_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)
CONFIG_ID_FILE = $(CURR_DIR)/$(APP)-CONFIG_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)
COMPILE_ID_FILE = $(CURR_DIR)/$(APP)-COMPILE_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)

.PHONY: gcc libgcc install clean distclean shell

$(GIT_ID_FILE) :
	git clone --depth=1 --branch releases/$(BRANCH) $(LOC) $(APP) 1>$(GIT_ID_FILE) 2>&1 || true
	

$(BUILD_HOST_DL)/$(GMP_FILE) :
	wget -O $(DL)/$(GMP_FILE) $(GMP_LOC)/$(GMP_FILE)
	
$(BUILD_HOST_DL)/$(MPFR_FILE) :
	wget -O $(BUILD_HOST_DL)/$(MPFR_FILE) $(MPFR_LOC)/$(MPFR_FILE)
	wget -O $(BUILD_HOST_DL)/$(MPFR_PATCH) $(MPFR_LOC)/$(MPFR_PATCH)
	
$(BUILD_HOST_DL)/$(MPC_FILE) :
	wget -O $(BUILD_HOST_DL)/$(MPC_FILE) $(MPC_LOC)/$(MPC_FILE)
	
$(BUILD_HOST_DL)/$(ISL_FILE) :
	wget -O $(BUILD_HOST_DL)/$(ISL_FILE) $(ISL_LOC)/$(ISL_FILE)
	
$(SOURCE_ID_FILE) : $(GIT_ID_FILE) $(BUILD_HOST_DL)/$(GMP_FILE) $(BUILD_HOST_DL)/$(MPFR_FILE) $(BUILD_HOST_DL)/$(MPC_FILE) $(BUILD_HOST_DL)/$(ISL_FILE)
	(for src in $(GCCADDS); do \
		mkdir -p $${src%%-*}; \
		tar -C $${src%%-*} --strip-components=1 -xkf $(BUILD_HOST_DL)/$$src.tar.*; \
		ln -sr $${src%%-*} $(APP)/$${src%%-*}; \
	done 1>>$(SOURCE_ID_FILE) 2>&1 || true)
	@echo "$(GCCADDS) are untarred"

$(PATCH_ID_FILE) : $(SOURCE_ID_FILE)
	-patch -d mpfr -N -Z -p1 < $(BUILD_HOST_DL)/$(MPFR_PATCH) 1>$(PATCH_ID_FILE) 2>&1

$(CONFIG_ID_FILE) : $(PATCH_ID_FILE)
	@mkdir -p build-$(APP)
	@cd build-$(APP); ../$(APP)/configure $(CONFIGURE_ARGS) 1>$(CONFIG_ID_FILE) 2>&1
	@echo "$(APP) is configured"

gcc : $(CONFIG_ID_FILE)
	$(MAKE) -C build-$(APP) $(MAKE_OPTS) all-gcc
	$(MAKE) -C build-$(APP) install-strip-gcc

libgcc : $(CONFIG_ID_FILE)
	if [ ! -e $(LIBC_SO) ] ; then \
		$(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)-gcc -Wl,-soname,libc.so.0 -nostdlib -nostartfiles -shared -x c /dev/null -o $(LIBC_SO).fake; \
		ln -srf $(LIBC_SO).fake $(LIBC_SO); \
	fi
	[ ! -e $(TOOLCHAIN_SYSROOT)/lib/crti.o ] && ln -sr $(TOOLCHAIN_SYSROOT)/usr/lib/crt*.o $(TOOLCHAIN_SYSROOT)/lib/ || true
	$(MAKE) -C build-$(APP) $(MAKE_OPTS) all-target-libgcc
	$(MAKE) -C build-$(APP) install-strip-target-libgcc
	[ -e $(LIBC_SO).fake ] && rm $(LIBC_SO) $(LIBC_SO).fake || true
	[ -L $(TOOLCHAIN_SYSROOT)/lib/crti.o ] && rm `find $(TOOLCHAIN_SYSROOT)/lib -type l -name crt*.o`
	ln -sfr $(TOOLCHAIN_SYSROOT)/../lib/gcc/$(TOOLCHAIN_PREFIX)/`$(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)-gcc -dumpversion`/libgcc_s.so.1 $(TOOLCHAIN_SYSROOT)/lib

install : $(CONFIG_ID_FILE)
	[ ! -e $(TOOLCHAIN_SYSROOT)/lib/crti.o ] && ln -sr $(TOOLCHAIN_SYSROOT)/usr/lib/crt*.o $(TOOLCHAIN_SYSROOT)/lib/ || true
	$(MAKE) -C build-$(APP) $(MAKE_OPTS)
	$(MAKE) -C build-$(APP) install-strip
	[ -L $(TOOLCHAIN_SYSROOT)/lib/crti.o ] && rm `find $(TOOLCHAIN_SYSROOT)/lib -type l -name crt*.o`
	for lib in libstdc++.so.6 libitm.so.1 libatomic.so.1; do \
		ln -sfr $(TOOLCHAIN_SYSROOT)/../lib/gcc/$(TOOLCHAIN_PREFIX)/`$(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)-gcc -dumpversion`/$$lib $(TOOLCHAIN_SYSROOT)/lib; \
	done


clean:
	$(MAKE) -C build-$(APP) distclean
	rm -rf $(COMPILE_ID_FILE) $(CONFIG_ID_FILE)

distclean:
	for src in $(GCCADDS) ; do rm -rf $${src%%-*} ; done
	rm -rf build-$(APP) $(APP) $(APP)-*_ID_*

# Shell target permits creating an interacive shell for debugging
shell:
	bash -i


