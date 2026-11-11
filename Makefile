TARGET := iphone:clang:latest:13.0
ARCHS := arm64 arm64e
INSTALL_TARGET_PROCESSES := Telegram

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := TelatgerVisuals
TelatgerVisuals_FILES := Tweak.xm
TelatgerVisuals_FRAMEWORKS := UIKit
TelatgerVisuals_CFLAGS := -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
