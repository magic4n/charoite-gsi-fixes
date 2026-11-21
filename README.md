# Xiaomi Redmi Note 15 Pro 4G (`charoite`) GSI Fixes

Magisk module providing core hardware adaptations for Generic System Images (GSI) on Xiaomi Redmi Note 15 Pro 4G (`charoite`) with HyperOS 3 vendor (EEA / Global).

## Supported Environments
- **Target Device:** Redmi Note 15 Pro 4G (`charoite`)
- **Stock Vendor Base:** HyperOS 3 (`OS3.0.304.0.WPFEUXM` / `OS3.0.304.0.WPFMIXM`)
- **System Images:** Android 16 & Android 17 GSIs (AOSP, LineageOS, Lunaris, Infinity-X, PixelExperience)
- **Root Solution:** Magisk 26+ / Magisk Canary

## Features
- **Backlight Control (1-4095 range):** Patched AIDL lights binary prevents SIGSEGV on device init, bypasses inactive sysfs clone nodes, and writes directly to `/sys/class/leds/lcd-backlight/brightness`. Resolves property conflicts causing brightness capping.
- **Refresh Rate & Anti-Flicker:** Disables SurfaceFlinger idle timeout and enforces 120Hz/60Hz modes to prevent 30Hz drop-down PWM flicker. Enables DC Dimming (`dc_status=1`).
- **Camera Cutout & Status Bar:** Framework and SystemUI runtime resource overlays for centered camera cutout and 36dp status bar height.
- **SELinux Compatibility:** Custom policies in `sepolicy.rule` for smooth execution under Enforcing mode.

## Installation
1. Download `charoite_fixes_module_v2.zip` from releases.
2. Flash the zip in Magisk Manager.
3. Reboot device.

## Building
Run `build.bat` on Windows or package using standard zip tool:
```bash
zip -r charoite_fixes.zip module.prop post-fs-data.sh service.sh sepolicy.rule META-INF system
```

## Documentation
- English: `README.md`
- Russian: `README_RU.md`

## License
MIT License. Developed by BootFox.
