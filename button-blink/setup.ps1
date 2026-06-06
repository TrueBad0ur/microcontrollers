# ATtiny85 build & flash script
# Usage: .\flash.ps1 <source.c>

param(
    [string]$Source = "button.c"
)

$GCC     = "C:\Users\truebad0ur\Documents\Tools\Micro\avr-gcc-15.2.0-x64-windows\bin"
$AVRDUDE = "C:\Users\truebad0ur\Documents\Tools\Micro\avrdude\avrdude.exe"
$ELF     = [System.IO.Path]::ChangeExtension($Source, "elf")
$HEX     = [System.IO.Path]::ChangeExtension($Source, "hex")

# 1. Check USBasp driver
Write-Host ""
Write-Host "[1/4] Checking USBasp driver..." -ForegroundColor Cyan
$usbasp = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*USBasp*" }
if ($usbasp) {
    Write-Host "      OK - USBasp found: $($usbasp.FriendlyName)" -ForegroundColor Green
} else {
    Write-Host "      WARNING - USBasp not found. Check USB or reinstall driver via Zadig." -ForegroundColor Yellow
}

# 2. Ping chip
Write-Host ""
Write-Host "[2/4] Detecting ATtiny85..." -ForegroundColor Cyan
$detect = & $AVRDUDE -c usbasp -p t85 -v 2>&1
if ($detect -match "ATtiny85") {
    Write-Host "      OK - ATtiny85 detected" -ForegroundColor Green
} else {
    Write-Host "      ERROR - chip not responding. Check wiring." -ForegroundColor Red
    Write-Host $detect
    exit 1
}

# 3. Compile
Write-Host ""
Write-Host "[3/4] Compiling $Source..." -ForegroundColor Cyan
& "$GCC\avr-gcc.exe" -mmcu=attiny85 -DF_CPU=1000000UL -Os -o $ELF $Source
if ($LASTEXITCODE -ne 0) {
    Write-Host "      ERROR - compilation failed." -ForegroundColor Red
    exit 1
}
& "$GCC\avr-objcopy.exe" -O ihex $ELF $HEX
if ($LASTEXITCODE -ne 0) {
    Write-Host "      ERROR - objcopy failed." -ForegroundColor Red
    exit 1
}
$size = (Get-Item $HEX).Length
Write-Host "      OK - compiled: $HEX ($size bytes)" -ForegroundColor Green

# 4. Flash
Write-Host ""
Write-Host "[4/4] Flashing..." -ForegroundColor Cyan
$flash = & $AVRDUDE -c usbasp -p t85 -U "flash:w:${HEX}:i" 2>&1
if ($flash -match "verified") {
    Write-Host "      OK - flash verified successfully" -ForegroundColor Green
} else {
    Write-Host "      ERROR - flash failed." -ForegroundColor Red
    Write-Host $flash
    exit 1
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green