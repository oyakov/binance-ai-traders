@echo off
REM Quick rebuild script for binance-data-collection-testnet
REM This is the fastest way to rebuild when only source code changes

echo 🚀 Quick Rebuild - binance-data-collection-testnet
echo ================================================

cd /d "C:\Projects\binance-ai-traders"

echo 🔨 Building with cache...
docker-compose -f docker-compose-testnet.yml build binance-data-collection-testnet

if %ERRORLEVEL% EQU 0 (
    echo ✅ Build successful!
    echo.
    echo 💡 To start the service:
    echo    docker-compose -f docker-compose-testnet.yml up -d binance-data-collection-testnet
) else (
    echo ❌ Build failed!
    echo 💡 Try running: build-data-collection-fast.ps1 -Clean
)

pause
