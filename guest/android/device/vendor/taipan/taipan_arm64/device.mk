# SPDX-License-Identifier: GPL-2.0-only
LOCAL_PATH := $(call my-dir)

PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/fstab.taipan-virt:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.taipan-virt \
	$(LOCAL_PATH)/init.taipan-virt.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.taipan-virt.rc \
	$(LOCAL_PATH)/manifest.xml:$(TARGET_COPY_OUT_VENDOR)/etc/vintf/manifest.xml
