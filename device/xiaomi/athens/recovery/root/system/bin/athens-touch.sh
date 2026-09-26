#!/system/bin/sh
# focaltech_ts_fw_athens.bin reports version 33. The built-in fallback (06)
# cannot report native coordinates; leave a clear failure if loading it fails.
touch_path=/sys/bus/spi/devices/spi19.0
attempt=0
while [ "$attempt" -lt 50 ]; do
    if [ "$(cat "$touch_path/fts_fw_version" 2>/dev/null)" = "33" ]; then
        echo 0 > /sys/class/touch/touch_dev/enable_touch_raw || exit 1
        echo "athens-touch: firmware 33 ready, native coordinates enabled" > /dev/kmsg
        exit 0
    fi
    sleep 0.1
    attempt=$((attempt + 1))
done
echo "athens-touch: firmware 33 did not become ready" > /dev/kmsg
exit 1
