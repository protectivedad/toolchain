#
# In most cases, you only need to modify this first section.
#
CURR_DIR := $(shell pwd)
BUILD_DIR:=$(subst /elfkickers, /elfkickers,$(CURR_DIR))
BUILD_DIR:=$(word 1, $(BUILD_DIR))
export BUILD_DIR

include $(BUILD_DIR)/make.common

unexport TARGET_ARCH

all: install

CURR_DIR := $(shell pwd)

APP=sstrip
LIB=elfrw
LOC=https://github.com/BR903/ELFkickers.git/trunk/

SOURCE_ID_FILE = $(CURR_DIR)/$(APP)-SOURCE_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)
COMPILE_ID_FILE = $(CURR_DIR)/$(APP)-COMPILE_ID_$(TOOLCHAIN_PREFIX)_$(LINUX_VER_STR)

.PHONY: install clean distclean shell

$(SOURCE_ID_FILE) :
	svn export $(LOC)/$(LIB) $(LIB) 1>$(SOURCE_ID_FILE) 2>&1
	@echo "$(LIB) is pulled"
	svn export $(LOC)/$(APP) $(APP) 1>>$(SOURCE_ID_FILE) 2>&1
	@echo "$(APP) is pulled"

$(COMPILE_ID_FILE) : $(SOURCE_ID_FILE)
	$(MAKE) -C $(APP) 1>$(COMPILE_ID_FILE) 2>&1

install : $(COMPILE_ID_FILE)
	install -m 755 $(APP)/sstrip $(TOOLCHAIN)/bin/$(TOOLCHAIN_PREFIX)-sstrip

clean:
	$(MAKE) -C $(APP) clean
	$(MAKE) -C $(LIB) clean
	-rm -f $(COMPILE_ID_FILE)

distclean:
	rm -rf $(APP) $(LIB) $(APP)-*_ID_*

# Shell target permits creating an interacive shell for debugging
shell:
	bash -i


