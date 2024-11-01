TARGET = iphone:clang:latest:15.0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = Weibo


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WBNoAds

WBNoAds_FILES = Tweak.x
WBNoAds_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
