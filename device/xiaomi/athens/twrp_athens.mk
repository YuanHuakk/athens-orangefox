$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, device/xiaomi/athens/device.mk)

PRODUCT_NAME := twrp_athens
PRODUCT_DEVICE := athens
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := REDMI K100 Pro
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_RELEASE_NAME := athens
