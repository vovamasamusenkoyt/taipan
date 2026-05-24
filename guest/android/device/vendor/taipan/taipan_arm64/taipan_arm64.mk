# SPDX-License-Identifier: GPL-2.0-only
LOCAL_PATH := $(call my-dir)

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(LOCAL_PATH)/device.mk)

PRODUCT_NAME := taipan_arm64
PRODUCT_DEVICE := taipan_arm64
PRODUCT_BRAND := Taipan
PRODUCT_MODEL := Taipan Virtual Device
PRODUCT_MANUFACTURER := Taipan
