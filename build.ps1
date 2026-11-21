# Build flashable Magisk module zip
$ErrorActionPreference = "Stop"
$outZip = "charoite_fixes_module_v2.zip"
Write-Host "Packaging $outZip..." -ForegroundColor Cyan

if (Test-Path $outZip) {
    Remove-Item $outZip -Force
}

tar -a -cf $outZip module.prop post-fs-data.sh service.sh sepolicy.rule META-INF system
Write-Host "Done! Output: $outZip ($((Get-Item $outZip).Length) bytes)" -ForegroundColor Green
