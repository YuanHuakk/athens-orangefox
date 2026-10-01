DEVICE_PATH := device/xiaomi/athens

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := generic
TARGET_BOARD_PLATFORM := canoe
TARGET_BOOTLOADER_BOARD_NAME := athens
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true

# Installer device assertion.
TARGET_OTA_ASSERT_DEVICE := athens

# Ramdisk-only recovery; boot/vendor_boot provide the kernel and DTB.
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_PAGESIZE := 4096
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
BOARD_RAMDISK_USE_LZ4 := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_RECOVERY_MKBOOTIMG_ARGS := --header_version 4 --pagesize 4096 --os_version 0 --os_patch_level 0

BOARD_AVB_ENABLE := true
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

BOARD_SUPER_PARTITION_SIZE := 16106127360
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 16095641600
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext product vendor odm vendor_dlkm system_dlkm mi_ext

# Create /vendor as a directory for the bundled HALs and VINTF files.
TARGET_COPY_OUT_VENDOR := vendor

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_HAS_LARGE_FILESYSTEM := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab

# Use matching 32-bit formats for DRM and pixelflinger.
# Keep the value unquoted for Soong JSON export.
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

TW_THEME := portrait_hdpi
TARGET_SCREEN_WIDTH := 1156
TARGET_SCREEN_HEIGHT := 2510
TW_BRIGHTNESS_PATH := /sys/class/backlight/panel0-backlight/brightness
TW_MAX_BRIGHTNESS := 16383
TW_DEFAULT_BRIGHTNESS := 2000
# Read battery status from sysfs.
OF_USE_LEGACY_BATTERY_SERVICES := 1
# CPU junction sensor cpu-0-0-0; thermal_zone0 contains a fixed trip point.
TW_CUSTOM_CPU_TEMP_PATH := /sys/class/thermal/thermal_zone7/temp
# PMH0101 channel 2 is the populated rear torch on athens.
OF_FL_PATH1 := /sys/class/leds/amber:flash-2
# The RTC is a counter, not Unix time. Use OrangeFox's saved per-device drift.
TARGET_RECOVERY_QCOM_RTC_FIX := true
OF_USE_LEGACY_TIME_FIXUP := 1
# Leave TW_NO_SCREEN_TIMEOUT unset: any nonempty value disables the unlock path.
TW_INCLUDE_REPACKTOOLS := false

# Use the device configfs rules for MTP and the base init rules for ADB.
# Leave TW_EXCLUDE_MTP unset; even a value of false excludes MTP.
TW_EXCLUDE_DEFAULT_USB_INIT := true
# Enable FBE and wrapped metadata keys through the bundled vendor HALs.
TW_INCLUDE_CRYPTO := true
TARGET_RECOVERY_DEVICE_MODULES += android.hardware.weaver-service.athens

# Load touch/NFC modules from vendor_dlkm. The loader also imports the ROM
# version and patch levels before KeyMint starts.
TW_LOAD_VENDOR_MODULES := "xiaomi_touch.ko focaltech_touch_3685g.ko nxp-nci.ko"

# HAL and keystore logging.
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true

# Include libsysutils in the ramdisk for FBE, libtar and fscryptpolicyget.
# Use recursive expansion so TARGET_OUT_SHARED_LIBRARIES resolves at use time.
TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libsysutils.so

TW_INCLUDE_FASTBOOTD := true
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := zh_CN
TW_DEVICE_VERSION := v1.4

# OrangeFox
OF_MAINTAINER := YuanHuakk
# Provide a button to unlock when touch raw mode prevents swipe gestures.
OF_USE_LOCKSCREEN_BUTTON := 1
# Install to the dedicated A/B recovery partitions.
OF_AB_DEVICE_WITH_RECOVERY_PARTITION := 1
OF_SCREEN_H := 2510
OF_STATUS_H := 100
OF_STATUS_INDENT_LEFT := 48
OF_STATUS_INDENT_RIGHT := 48
OF_CLOCK_POS := 1
OF_QUICK_BACKUP_LIST := /boot;/dtbo;

TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
