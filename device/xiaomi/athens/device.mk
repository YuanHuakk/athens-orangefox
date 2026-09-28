DEVICE_PATH := device/xiaomi/athens

PRODUCT_BUILD_RECOVERY_IMAGE := true
PRODUCT_BUILD_BOOT_IMAGE := false
PRODUCT_BUILD_INIT_BOOT_IMAGE := false
PRODUCT_BUILD_VENDOR_BOOT_IMAGE := false
PRODUCT_BUILD_SUPER_PARTITION := false
PRODUCT_BUILD_SUPER_EMPTY_IMAGE := false
PRODUCT_USE_DYNAMIC_PARTITIONS := true
# Runtime properties are required by update_engine and the recovery snapshot
# checks. Setting PRODUCT_VIRTUAL_AB_* alone does not emit these properties.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION_METHOD := lz4

AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot dtbo init_boot recovery vendor_boot vbmeta vbmeta_system \
    system system_ext product vendor odm vendor_dlkm system_dlkm mi_ext

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/init.recovery.qcom.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.qcom.rc \
    $(DEVICE_PATH)/recovery/root/init.recovery.usb.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.usb.rc \
    $(DEVICE_PATH)/recovery/root/ueventd.qcom.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/ueventd.rc

PRODUCT_PACKAGES += \
    android.hardware.boot-service.default_recovery \
    fastbootd \
    snapuserd.recovery
