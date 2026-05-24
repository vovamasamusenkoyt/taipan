# SPDX-License-Identifier: GPL-2.0-only
LOCAL_DIR := $(call my-dir)

PRODUCT_MAKEFILES := \
	$(LOCAL_DIR)/taipan_arm64.mk

COMMON_LUNCH_CHOICES := \
	taipan_arm64-userdebug
