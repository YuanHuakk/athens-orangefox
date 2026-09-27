#!/system/bin/sh
# focaltech_ts_fw_athens.bin reports version 33. The built-in fallback (06)
# cannot report native coordinates; leave a clear failure if loading it fails.
#
# enable_touch_raw has two sysfs routes to the same driver on this platform:
# /sys/class/touch is what athens was measured on, /sys/devices/virtual/touch is
# what the sibling songyuan tree uses. Both are probed rather than trusting the
# one that happens to work today, because a failed write used to exit silently
# and look identical to a healthy boot.
touch_path=/sys/bus/spi/devices/spi19.0
raw_paths="/sys/class/touch/touch_dev/enable_touch_raw /sys/devices/virtual/touch/touch_dev/enable_touch_raw"
attempt=0
while [ "$attempt" -lt 50 ]; do
    if [ "$(cat "$touch_path/fts_fw_version" 2>/dev/null)" = "33" ]; then
        for raw in $raw_paths; do
            [ -e "$raw" ] || continue
            if echo 0 > "$raw" 2>/dev/null; then
                echo "athens-touch: firmware 33 ready, native coordinates enabled via $raw" > /dev/kmsg
                exit 0
            fi
            echo "athens-touch: enable_touch_raw write rejected by $raw" > /dev/kmsg
        done
        echo "athens-touch: firmware 33 ready, but no enable_touch_raw node accepted the write" > /dev/kmsg
        exit 1
    fi
    sleep 0.1
    attempt=$((attempt + 1))
done
echo "athens-touch: firmware 33 did not become ready" > /dev/kmsg
exit 1
