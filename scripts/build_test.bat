@echo off
REM Build Test Script for Windows
REM Tests Android and iOS builds (if available)

echo ========================================
echo PokiFairy Build Test Script
echo ========================================
echo.

REM Run flutter analyze
echo [1/5] Running flutter analyze...
call flutter analyze
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: flutter analyze failed
    exit /b 1
)
echo flutter analyze passed!
echo.

REM Run unit tests
echo [2/5] Running unit tests...
call flutter test --no-pub
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Unit tests failed
    exit /b 1
)
echo Unit tests passed!
echo.

REM Build Android Debug APK
echo [3/5] Building Android Debug APK...
call flutter build apk --debug
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Android debug build failed
    exit /b 1
)
echo Android debug build successful!
echo.

REM Build Android Release APK
echo [4/5] Building Android Release APK...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Android release build failed
    exit /b 1
)
echo Android release build successful!
echo.

REM Check if iOS build is available (macOS only)
echo [5/5] Checking iOS build availability...
where xcodebuild >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Building iOS Debug...
    call flutter build ios --debug --no-codesign
    if %ERRORLEVEL% NEQ 0 (
        echo WARNING: iOS debug build failed
    ) else (
        echo iOS debug build successful!
    )
    
    echo Building iOS Release...
    call flutter build ios --release --no-codesign
    if %ERRORLEVEL% NEQ 0 (
        echo WARNING: iOS release build failed
    ) else (
        echo iOS release build successful!
    )
) else (
    echo iOS build skipped (not available on Windows)
)
echo.

echo ========================================
echo Build Test Complete!
echo ========================================
echo.
echo Build artifacts:
echo - Android Debug: build\app\outputs\flutter-apk\app-debug.apk
echo - Android Release: build\app\outputs\flutter-apk\app-release.apk
echo.

exit /b 0
