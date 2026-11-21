# Xiaomi Redmi Note 15 Pro 4G (`charoite`) — GSI Hardware Fixes v2.0

Комплект аппаратных фиксов в виде Magisk-модуля для запуска любых Generic System Images (**GSI**) Android 16 и Android 17 (AOSP, LineageOS, PixelExperience, Lunaris, Infinity-X и др.) на базе стокового вендора HyperOS 3 (**EEA** `OS3.0.304.0.WPFEUXM` и **Global/MI** `OS3.0.304.0.WPFMIXM`).

---

## 🚀 Основные возможности (Features)

* **Аппаратная регулировка подсветки (0..100%):**
  * Устранено падение службы `android.hardware.lights-service.mediatek` в `SIGSEGV` при первой установке яркости фреймворком (предотвращение "смерти экрана / death sleep").
  * Перенаправление команд напрямую в рабочий драйвер ядра: `/sys/class/leds/lcd-backlight/brightness`.
  * Линейное масштабирование диапазона `0..255` → `1..4095` (минимальное значение `1` не дает экрану погаснуть в ноль).
  * Автоматическое устранение конфликта с `persist.sys.qcom-brightness` (который резал максимальную яркость до ~14%).
* **Фиксация частоты обновления 120 Гц / 60 Гц (No Flicker):**
  * Отключение таймера простоя SurfaceFlinger (`debug.sf.set_idle_timer_ms = 0`), устраняющее падение частоты в 30 Гц при бездействии.
  * Блокировка постоянных скачков RDMA в ядре (`30 ↔ 120 Гц`) и мерцания дисплея.
  * Принудительное включение **DC Dimming** (`dc_status = 1`).
* **Камера и статус-бар (RRO Overlays):**
  * Центрированный вырез под фронтальную камеру (`cutout`).
  * Высота статус-бара `36.0dp` (`status_bar_height_portrait`), часы и иконки не перекрываются глазком камеры.
* **Полная совместимость с SELinux Enforcing:**
  * В комплект включены правила `sepolicy.rule` для Magisk, снимающие запреты `init` на запуск вендорных служб (`execute_no_trans`) и доступ к sysfs-узлам.

---

## 📁 Структура репозитория

```text
├── META-INF/
│   └── com/google/android/
│       ├── update-binary        # Инсталлятор модуля
│       └── updater-script       # Скрипт совместимости
├── system/
│   ├── bin/
│   │   ├── android.hardware.lights-service.mediatek  # Пропатченный ELF Lights HAL
│   │   └── phh-on-boot.sh       # Скрипт базовой инициализации GSI
│   ├── etc/
│   │   └── init/
│   │       └── charoite-lights.rc # Init-конфиг переопределения службы
│   ├── lib64/
│   │   ├── android.hardware.light-V2-ndk.so
│   │   └── vendor.mediatek.hardware.mtklight-V1-ndk.so
│   └── product/
│       └── overlay/
│           ├── treble-overlay-xiaomi-charoite.apk          # Оверлей выреза
│           └── treble-overlay-xiaomi-charoite-systemui.apk # Оверлей статус-бара
├── module.prop                  # Метаданные модуля Magisk
├── post-fs-data.sh              # Монтирование оверлеев и bind-mount бинарника
├── service.sh                   # Автозапуск: 120Hz lock, DC Dimming, рестарт HAL
├── sepolicy.rule                # Правила SELinux для Magisk
├── build.ps1 / build.bat        # Скрипты сборки flashable zip-архива
└── README.md
```

---

## 🛠 Техническое описание патчей (Для разработчиков)

### 1. Бинарный патч Lights HAL (`android.hardware.lights-service.mediatek`)
Бинарник идентичен для версий HyperOS 3 EEA (`OS3.0.304.0.WPFEUXM`) и MI (`OS3.0.304.0.WPFMIXM`):
* **Offset `0x4db4`:** `9F 02 04 6B` → `54 0D 00 34` (`cbz w20, 0x4f5c`). При запросе ID=0 управление сразу передается обработчику подсветки дисплея в обход пустого вектора устройств.
* **Offset `0x52f8`:** `C8 FF 83 52` → `C8 FF 81 52` (`mov w8, #4094`).
* **Offset `0x52fc`:** `A9 FF 83 12` → `A9 FF 81 12` (`mov w9, #-4094`). Изменение множителя формулы с 8190 на 4094 (линейная шкала `1..4095`).
* **Offset `0x539c`:** `E0 02 88 9A` → `E0 03 17 AA` (`mov x0, x23`). Принудительная запись значения в путь `/sys/class/leds/lcd-backlight/brightness` вместо неработающего `brightness_clone`.

### 2. Фиксация частоты и устранение ШИМ
В `service.sh` на раннем этапе загрузки выполняются:
```bash
resetprop persist.debug.disable_dynamic_fps 1
resetprop debug.sf.set_idle_timer_ms 0
cmd display set-user-preferred-display-mode 1080 2392 120.0
settings put system min_refresh_rate 120.0
settings put system peak_refresh_rate 120.0
echo 1 > /sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/dc_status
```

---

## 📦 Установка

1. Скачайте архив релиза **`charoite_fixes_module_v2.zip`**.
2. Откройте **Magisk Manager** → вкладка **Модули** → **Установить из хранилища**.
3. Выберите скачанный `.zip`.
4. Перезагрузите устройство.

---

## 🔨 Сборка из исходников

Для упаковки модуля в zip-архив запустите в PowerShell:
```powershell
.\build.ps1
```
или в командной строке:
```cmd
build.bat
```

---

## 📜 Лицензия
Apache 2.0 License. Автор: **BootFox**.
