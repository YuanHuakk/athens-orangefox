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

# Checked by the OrangeFox installer against the running device's ro.product.device
# (orangefox.mk maps this to FOX_TARGET_DEVICES).
TARGET_OTA_ASSERT_DEVICE := athens

# The stock recovery contains only a ramdisk; boot/vendor_boot supply the kernel and DTB.
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

# athens has a dedicated vendor partition (dumped from stock as vendor_a.img), and
# the stock recovery ramdisk carries /vendor as a real directory, not a symlink.
# The build has to agree, otherwise create_root_structure.mk takes its else branch
# and creates $(TARGET_ROOT_OUT)/vendor as a symlink to /system/vendor:
#
#   ifdef BOARD_USES_VENDORIMAGE
#     mkdir -p $(TARGET_ROOT_OUT)/vendor
#   else
#     ln -sf /system/vendor $(TARGET_ROOT_OUT)/vendor
#
# That symlink then collides with bootable/recovery/etc/Android.mk, which installs
# android.hardware.health@2.1.xml into $(TARGET_RECOVERY_ROOT_OUT)/vendor/etc/vintf/
# manifest, and with our own ueventd.qcom.rc copy into the same tree. The recovery
# ramdisk rule rsyncs $(TARGET_ROOT_OUT) over $(TARGET_RECOVERY_ROOT_OUT) and stops
# with "cannot delete non-empty directory: root/vendor".
#
# Setting TARGET_COPY_OUT_VENDOR is the switch that selects the real-directory
# branch: board_config.mk derives BOARD_USES_VENDORIMAGE from it, and soong_config.mk
# feeds the same value to Soong as VendorPath so both halves of the build agree.
# BOARD_USES_VENDORIMAGE itself cannot be set here - board_config.mk rejects it
# unless TARGET_COPY_OUT_VENDOR is already 'vendor'.
TARGET_COPY_OUT_VENDOR := vendor

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_HAS_LARGE_FILESYSTEM := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab

# libminuitwrp and libpixelflinger have to agree with the format the display
# backend picks. graphics_drm.cpp selects that format at compile time from the
# RECOVERY_* macros, and with none of them defined it falls to its #else branch:
#
#   format      = DRM_FORMAT_RGB565           (16bpp - what the panel is given)
#   base_format = GGL_PIXEL_FORMAT_BGRA_8888  (32bpp - what pixelflinger uses)
#
# pixel_bytes is derived from the DRM format, so it comes out as 2, while
# pixelflinger believes the surface is 32bpp and walks it with uint32_t strides
# (scanline_memset32 uses `reinterpret_cast<uint32_t*>(cb->data) + (x +
# cb->stride * y)`). At 1156x2510 the draw buffer is 2510 * 2312 = 5803120 bytes,
# but the last row lands at (1156 * 2509) * 4 = 11601616 - almost exactly twice
# the buffer. That is the crash: SEGV_ACCERR at a page-aligned heap address, on
# gr_fill -> recti -> rect_generic -> memset, immediately after "Switching
# packages (splash)". The same value is exported by sysprop_config.mk as
# ro.minui.pixel_format, which libminui reads.
#
# RGBX_8888 is TWRP's usual choice. It selects DRM_FORMAT_XBGR8888 together with
# GGL_PIXEL_FORMAT_RGBA_8888, both 32bpp, and resources.cpp already adjusts the
# channel order for that macro, so colours come out right.
#
# The value must stay unquoted. TWRP's own examples write it as "RGBX_8888", and
# libminuitwrp_defaults.go:69 strips quotes before matching, so both spellings
# select the same macro - but BoardConfigSoong.mk:19 also exports the variable
# through Soong's MakeVars JSON writer, which does not strip them. Quoted, the
# value reaches out/soong/soong.<product>.extra.variables as
#
#   "RecoveryPixelFormat": ""RGBX_8888"",
#
# and merge_json then aborts the build with "Error parsing JSON ... Expecting ','
# delimiter", reported against build/soong/product_config rather than this line.
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

TW_THEME := portrait_hdpi
TARGET_SCREEN_WIDTH := 1156
TARGET_SCREEN_HEIGHT := 2510
TW_BRIGHTNESS_PATH := /sys/class/backlight/panel0-backlight/brightness
TW_MAX_BRIGHTNESS := 16383
TW_DEFAULT_BRIGHTNESS := 2000
# Recovery has no Health HAL; read the kernel's real capacity/status directly.
OF_USE_LEGACY_BATTERY_SERVICES := 1
# CPU temperature for the status bar and lockscreen. TWRP's default path is
# /sys/class/thermal/thermal_zone0/temp, which is wrong on athens: zone0 is
# cpu-hw-trip-0, a hardware trip-point register that reads a constant 95000
# (95 degrees) regardless of load, so the UI showed a frozen 95.
#
# The actual CPU junction sensors are the per-core TSENS entries. Measured swing
# under an 8-thread spin: cpu-0-0-0 41500 -> 80300, cpu-1-0-1 48400 -> 81100.
# cpu_therm (zone68) reacts too, but it is a board thermistor with roughly half
# the swing (39696 -> 58578) and a lag, so a core sensor is the better source.
# thermal_zone7 is cpu-0-0-0 - cluster 0, core 0.
TW_CUSTOM_CPU_TEMP_PATH := /sys/class/thermal/thermal_zone7/temp
# PMH0101 channel 2 is the populated rear torch on athens.
OF_FL_PATH1 := /sys/class/leds/amber:flash-2
# The RTC is a counter, not Unix time. Use OrangeFox's saved per-device drift.
TARGET_RECOVERY_QCOM_RTC_FIX := true
OF_USE_LEGACY_TIME_FIXUP := 1
# Screen timeout and the lockscreen are coupled, and the coupling is a trap.
# gui/blanktimer.cpp guards BOTH checkForTimeout() and resetTimerAndUnblank()
# behind TW_NO_SCREEN_TIMEOUT, while gui.cpp's toggleBlank() (power key) is not
# guarded. So defining the macro stops the screen timing out but also compiles
# out the only path that dismisses the lockscreen - press power once and the
# device is stuck there with no way back into the UI.
#
# TW_NO_SCREEN_TIMEOUT must therefore stay UNDEFINED, and undefined means absent:
# bootable/recovery/Android.mk tests it with `ifneq ($(TW_NO_SCREEN_TIMEOUT),)`,
# which is true for any non-empty value, so `:= false` would trip the same trap
# as `:= true`. Do not add the variable in any form.
#
# Two consequences follow, and both are handled elsewhere:
#   - The timeout stays at its 60 second default and the lockscreen still
#     appears. OF_USE_LOCKSCREEN_BUTTON below gives it a tap target, because
#     the drag-up gesture is unreliable while the touch driver is in raw
#     reporting mode (see athens-touch.sh).
#   - Anyone who wants the screen to stop timing out entirely has to change the
#     default value in the source instead of using the macro. The sibling
#     myron/songyuan trees do that with a build-time patch to blanktimer.cpp.
TW_INCLUDE_REPACKTOOLS := false

# USB. TWRP's own etc/init.rc builds the recovery gadget whenever
# sys.usb.configfs=1, which init.recovery.qcom.rc sets: adb, sideload and
# fastboot all run off that, with ids from the ro.recovery.usb.* properties
# base_vendor.mk supplies. Its bundled init.recovery.usb.rc is excluded because
# it drives the legacy /sys/class/android_usb/android0 interface, which SM8850
# does not have. The device tree ships init.recovery.usb.rc in its place, which
# only has to carry what init.rc lacks.
#
# MTP is deliberately not excluded. The test is ifeq ($(TW_EXCLUDE_MTP),), so
# setting it to false would still compile MTP out - the variable has to stay
# undefined. See recovery/root/init.recovery.usb.rc for the FunctionFS wiring
# it needs, which TWRP's own init.rc does not provide.
TW_EXCLUDE_DEFAULT_USB_INIT := true
# FBE decryption. athens encrypts /data with
#   fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0
#   metadata_encryption=aes-256-xts:wrappedkey_v0
#   keydirectory=/metadata/vold/metadata_encryption
# so the metadata key is sealed to a hardware key and only the TEE can unwrap it.
# The HALs that do the unwrapping are staged under recovery/root/vendor and wired
# up in init.recovery.qcom.rc.
#
# TW_INCLUDE_CRYPTO forces TW_INCLUDE_CRYPTO_FBE and -DTW_INCLUDE_FBE, and adds
# -DTW_INCLUDE_FBE_METADATA_DECRYPT, which is the path that matters here.
TW_INCLUDE_CRYPTO := true
TARGET_RECOVERY_DEVICE_MODULES += android.hardware.weaver-service.athens

# The touchscreen modules live on vendor_dlkm, outside modules.load.recovery
# in vendor_boot. The loader also imports the installed OS/vendor patch levels
# before init starts KeyMint via keymaster_ver.
TW_LOAD_VENDOR_MODULES := "xiaomi_touch.ko focaltech_touch_3685g.ko nxp-nci.ko"

# Keep HAL/keystore diagnostics available during bring-up.
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true

# The crypto block is also what pulls libsysutils into the recovery binary:
# bootable/recovery/Android.mk:357 opens the TW_INCLUDE_CRYPTO branch and line
# 378 lists libsysutils among the FBE metadata-decrypt dependencies. The only
# code that ever copies libsysutils.so into the ramdisk, though, is
# prebuilt/Android.mk:380, nested inside `TWRP_INCLUDE_LOGCAT && TARGET_USES_LOGD`
# - and neither of those is set anywhere in the tree, only read. So the library
# was never staged, and the dynamic linker aborts /system/bin/recovery on startup
# with "library libsysutils.so not found", which is indistinguishable from a hang
# on the bootloader logo. libtar.so and fscryptpolicyget need it as well.
#
# TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES is TWRP's own extension point for
# device-specific ramdisk libraries (prebuilt/Android.mk:350). Naming the module
# here also feeds relink_libraries' LOCAL_REQUIRED_MODULES, so it is built before
# relink.sh runs instead of being silently dropped by that script's `-e $src`
# guard. Written with '+=' on an undefined variable, i.e. recursively expanded,
# so TARGET_OUT_SHARED_LIBRARIES resolves at point of use.
TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libsysutils.so

TW_INCLUDE_FASTBOOTD := true
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := zh_CN
TW_DEVICE_VERSION := v1.0

# OrangeFox
OF_MAINTAINER := YuanHuakk
# Puts a tappable unlock button on the lockscreen. Unlocking by swiping is a
# drag gesture, and the touch driver drops drags while it is in raw reporting
# mode, so a swipe-only lockscreen can strand the user. See the screen timeout
# block above for why the lockscreen cannot simply be disabled instead.
OF_USE_LOCKSCREEN_BUTTON := 1
# athens is A/B *and* keeps a dedicated recovery partition, so the installer must
# not treat it as a recovery-as-boot/vendor_boot-recovery device.
OF_AB_DEVICE_WITH_RECOVERY_PARTITION := 1
OF_SCREEN_H := 2510
OF_STATUS_H := 100
OF_STATUS_INDENT_LEFT := 48
OF_STATUS_INDENT_RIGHT := 48
OF_CLOCK_POS := 1
OF_QUICK_BACKUP_LIST := /boot;/dtbo;

TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
