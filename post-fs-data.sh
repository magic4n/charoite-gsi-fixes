#!/system/bin/sh
MODDIR=${0%/*}

# Prevent GSI framework from misinterpreting backlight scale as qcom
resetprop --delete persist.sys.qcom-brightness 2>/dev/null || true

# Ensure correct permissions
chmod 755 "$MODDIR/system/bin/"*
chmod 644 "$MODDIR/system/lib64/"*
chmod 644 "$MODDIR/system/product/overlay/"*
chcon -R u:object_r:system_file:s0 "$MODDIR/system"
chcon u:object_r:mtk_hal_light_exec:s0 "$MODDIR/system/bin/android.hardware.lights-service.mediatek"

# Overlayfs for overlays (so PackageManager scans them before boot complete)
WORK_DIR="/data/adb/overlay_work"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
chcon -R u:object_r:system_file:s0 "$WORK_DIR"
mount -t overlay overlay -o lowerdir=/system/product/overlay,upperdir=$MODDIR/system/product/overlay,workdir=$WORK_DIR /system/product/overlay 2>/dev/null || true

# Bind mounts
if [ -f "$MODDIR/system/bin/android.hardware.lights-service.mediatek" ]; then
    mount --bind "$MODDIR/system/bin/android.hardware.lights-service.mediatek" /vendor/bin/hw/android.hardware.lights-service.mediatek
    chcon u:object_r:mtk_hal_light_exec:s0 /vendor/bin/hw/android.hardware.lights-service.mediatek
fi

if [ -f "$MODDIR/system/bin/phh-on-boot.sh" ]; then
    mount --bind "$MODDIR/system/bin/phh-on-boot.sh" /system/bin/phh-on-boot.sh
fi

if [ -f "$MODDIR/system/lib64/android.hardware.light-V2-ndk.so" ]; then
    mount --bind "$MODDIR/system/lib64/android.hardware.light-V2-ndk.so" /system/lib64/android.hardware.light-V2-ndk.so 2>/dev/null || true
fi

if [ -f "$MODDIR/system/lib64/vendor.mediatek.hardware.mtklight-V1-ndk.so" ]; then
    mount --bind "$MODDIR/system/lib64/vendor.mediatek.hardware.mtklight-V1-ndk.so" /system/lib64/vendor.mediatek.hardware.mtklight-V1-ndk.so 2>/dev/null || true
fi
