@echo off
REM 릴리즈 빌드 생성 스크립트
REM Task 18.5: 최종 빌드 및 배포 준비

echo ========================================
echo PokiFairy 릴리즈 빌드
echo ========================================
echo.

REM 현재 디렉토리 저장
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%.."

echo [1/5] 의존성 확인 중...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 의존성 설치 실패
    exit /b 1
)
echo ✓ 의존성 확인 완료
echo.

echo [2/5] 코드 정리 중...
call flutter clean
echo ✓ 코드 정리 완료
echo.

echo [3/5] Android Release APK 빌드 중...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Android Release 빌드 실패
    exit /b 1
)
echo ✓ Android Release APK 빌드 완료
echo.

echo [4/5] Android App Bundle 빌드 중...
call flutter build appbundle --release
if %ERRORLEVEL% NEQ 0 (
    echo ⚠ Android App Bundle 빌드 실패
) else (
    echo ✓ Android App Bundle 빌드 완료
)
echo.

echo [5/5] 빌드 결과 확인 중...
echo.
echo 빌드 파일 위치:
echo - APK: build\app\outputs\flutter-apk\app-release.apk
echo - App Bundle: build\app\outputs\bundle\release\app-release.aab
echo.

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✓ APK 파일 생성 확인
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do (
        echo   크기: %%~zA bytes
    )
) else (
    echo ❌ APK 파일을 찾을 수 없습니다
)
echo.

if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo ✓ App Bundle 파일 생성 확인
    for %%A in ("build\app\outputs\bundle\release\app-release.aab") do (
        echo   크기: %%~zA bytes
    )
) else (
    echo ⚠ App Bundle 파일을 찾을 수 없습니다
)
echo.

echo ========================================
echo 릴리즈 빌드 완료!
echo ========================================
echo.
echo 다음 단계:
echo 1. APK 파일을 실제 기기에서 테스트
echo 2. Google Play Console에 App Bundle 업로드
echo 3. 릴리즈 노트 작성
echo.

pause
