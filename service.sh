#!/system/bin/sh
MODDIR=${0%/*}

# Delete bad props that break GSI brightness calculation
resetprop --delete persist.sys.qcom-brightness 2>/dev/null || true

# Disable dynamic FPS and surfaceflinger idle timer
resetprop persist.debug.disable_dynamic_fps 1
resetprop debug.sf.set_idle_timer_ms 0
resetprop persist.debug.set_idle_timer_ms 0
resetprop persist.sys.sf.set_idle_timer_ms 0

# Restart lights HAL to ensure it binds to binder servicemanager
setprop ctl.restart vendor.light-default

# Run phh-on-boot fixes (PWM, 120Hz/60Hz, audio, zram, netd)
if [ -f "$MODDIR/system/bin/phh-on-boot.sh" ]; then
    sh "$MODDIR/system/bin/phh-on-boot.sh"
fi

# Background task: wait for boot complete, ensure 120Hz lock, DC dimming, and overlays
(
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 2
    done
    sleep 3
    
    # Lock display to 120Hz globally (no drops to 30Hz)
    cmd display set-user-preferred-display-mode 1080 2392 120.0 2>/dev/null || true
    settings put system peak_refresh_rate 120.0
    settings put system min_refresh_rate 120.0
    
    # Lock DC dimming
    [ -f /sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/dc_status ] && echo 1 > /sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/dc_status
    
    # Overlays
    cmd overlay enable --user current me.phh.treble.overlay.xiaomi.charoite 2>/dev/null || true
    cmd overlay enable --user current me.phh.treble.overlay.xiaomi.charoite.systemui 2>/dev/null || true
) &
