#############################################################
#
# at91bootstrap
#
#############################################################
AT91BOOTSTRAP_VERSION:=2.3
AT91BOOTSTRAP_NAME:=at91bootstrap-$(AT91BOOTSTRAP_VERSION)
ATMEL_MIRROR:=$(strip  $(subst ",, $(BR2_ATMEL_MIRROR)))
AT91BOOTSTRAP_SITE:=$(ATMEL_MIRROR)
AT91BOOTSTRAP_SOURCE:=$(AT91BOOTSTRAP_NAME).tar.bz2
AT91BOOTSTRAP_DIR:=$(PROJECT_BUILD_DIR)/$(AT91BOOTSTRAP_NAME)
AT91BOOTSTRAP:=$(strip  $(subst ",, $(BR2_AT91BOOTSTRAP)))
AT91BOOTSTRAP_ZCAT:=bzcat

AT91BOOTSTRAP_MEMORY:=$(strip  $(subst ",, $(BR2_TARGET_AT91BOOTSTRAP_MEMORY)))


AT91BOOTSTRAP_BINARY:=$(BOARD_NAME)-$(AT91BOOTSTRAP_MEMORY)boot-$(AT91BOOTSTRAP_VERSION).bin

AT91BOOTSTRAP_TARGET:=$(AT91BOOTSTRAP_DIR)/binaries/$(AT91BOOTSTRAP_BINARY)

$(DL_DIR)/$(AT91BOOTSTRAP_SOURCE):
	 $(WGET) -P $(DL_DIR) $(AT91BOOTSTRAP_SITE)/$(AT91BOOTSTRAP_SOURCE)

$(AT91BOOTSTRAP_DIR)/.unpacked: $(DL_DIR)/$(AT91BOOTSTRAP_SOURCE)
	mkdir -p $(PROJECT_BUILD_DIR)
	$(AT91BOOTSTRAP_ZCAT) $(DL_DIR)/$(AT91BOOTSTRAP_SOURCE) | tar -C $(PROJECT_BUILD_DIR) $(TAR_OPTIONS) -
	touch $(AT91BOOTSTRAP_DIR)/.unpacked

$(AT91BOOTSTRAP_DIR)/.configured: $(AT91BOOTSTRAP_DIR)/.unpacked .config
	$(MAKE)					\
		MEMORY=$(AT91BOOTSTRAP_MEMORY)	\
		CROSS_COMPILE=$(TARGET_CROSS)	\
		-C $(AT91BOOTSTRAP_DIR)		\
		$(BOARD_NAME)_defconfig
	touch	$(AT91BOOTSTRAP_DIR)/.configured

$(AT91BOOTSTRAP_TARGET): $(AT91BOOTSTRAP_DIR)/.configured
	$(MAKE)					\
		MEMORY=$(AT91BOOTSTRAP_MEMORY)	\
		CROSS_COMPILE=$(TARGET_CROSS)	\
		-C $(AT91BOOTSTRAP_DIR)

at91bootstrap-source: $(DL_DIR)/$(AT91BOOTSTRAP_SOURCE)

at91bootstrap-clean:
	make -C $(AT91BOOTSTRAP_DIR) clean

at91bootstrap-dirclean:
	rm -rf $(AT91BOOTSTRAP_DIR)

at91bootstrap:	$(BINARIES_DIR)/$(AT91BOOTSTRAP_BINARY)

$(BINARIES_DIR)/$(AT91BOOTSTRAP_BINARY):	$(AT91BOOTSTRAP_TARGET)
	mkdir -p $(BINARIES_DIR)
	cp $(AT91BOOTSTRAP_TARGET)	$(BINARIES_DIR)/$(AT91BOOTSTRAP_BINARY)
	cp $(AT91BOOTSTRAP_TARGET)	/tftpboot/$(AT91BOOTSTRAP_BINARY)

.PHONY:	at91bootstrap
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_TARGET_AT91BOOTSTRAP)),y)
TARGETS+=at91bootstrap
endif
