@echo off
REM Comprehensive Test Runner for Windows
REM Runs all types of tests: unit, widget, and integration

echo ========================================
echo PokiFairy Comprehensive Test Runner
echo ========================================
echo.

REM Run flutter analyze
echo [1/4] Running flutter analyze...
call flutter analyze
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: flutter analyze failed
    pause
    exit /b 1
)
echo flutter analyze passed!
echo.

REM Run all unit and widget tests
echo [2/4] Running unit and widget tests...
call flutter test --no-pub --coverage
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Tests failed
    pause
    exit /b 1
)
echo All tests passed!
echo.

REM Run integration tests (requires connected device)
echo [3/4] Checking for connected devices...
call flutter devices
echo.
echo Do you want to run integration tests? (requires connected device)
echo Press Y to run integration tests, or any other key to skip...
choice /C YN /N /M "Run integration tests? [Y/N]: "
if %ERRORLEVEL% EQU 1 (
    echo Running integration tests...
    call flutter test integration_test/app_test.dart
    if %ERRORLEVEL% NEQ 0 (
        echo WARNING: Integration tests failed
    ) else (
        echo Integration tests passed!
    )
) else (
    echo Integration tests skipped
)
echo.

REM Generate test coverage report
echo [4/4] Test coverage report...
if exist coverage\lcov.info (
    echo Coverage report generated at: coverage\lcov.info
    echo To view coverage report, use: genhtml coverage\lcov.info -o coverage\html
) else (
    echo No coverage data generated
)
echo.

echo ========================================
echo Test Run Complete!
echo ========================================
echo.

pause
exit /b 0
