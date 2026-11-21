@echo off
set OUT_ZIP=charoite_fixes_module_v2.zip
echo Packaging %OUT_ZIP%...
if exist %OUT_ZIP% del /f /q %OUT_ZIP%
tar -a -cf %OUT_ZIP% module.prop post-fs-data.sh service.sh sepolicy.rule META-INF system
echo Done! %OUT_ZIP% created successfully.
pause
