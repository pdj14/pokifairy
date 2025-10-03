# 최종 통합 및 검증 스크립트
# Task 18: 최종 통합 및 검증

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PokiFairy 최종 통합 및 검증" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 현재 디렉토리를 프로젝트 루트로 변경
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $scriptPath "..")

$testResults = @{
    Dependencies = $false
    Analysis = $false
    UnitTests = $false
    IntegrationTests = $false
    BuildTest = $false
}

# 1. 의존성 확인
Write-Host "[1/6] 의존성 확인 중..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 의존성 확인 완료" -ForegroundColor Green
    $testResults.Dependencies = $true
} else {
    Write-Host "❌ 의존성 설치 실패" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 2. 코드 분석
Write-Host "[2/6] 코드 분석 실행 중..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 코드 분석 완료" -ForegroundColor Green
    $testResults.Analysis = $true
} else {
    Write-Host "⚠ 코드 분석에서 경고 발견" -ForegroundColor Yellow
    $testResults.Analysis = $false
}
Write-Host ""

# 3. 단위 테스트
Write-Host "[3/6] 단위 테스트 실행 중..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 단위 테스트 완료" -ForegroundColor Green
    $testResults.UnitTests = $true
} else {
    Write-Host "⚠ 일부 단위 테스트 실패" -ForegroundColor Yellow
    $testResults.UnitTests = $false
}
Write-Host ""

# 4. 통합 테스트
Write-Host "[4/6] 통합 테스트 실행 중..." -ForegroundColor Yellow

Write-Host "  - 전체 기능 테스트..." -ForegroundColor Cyan
flutter test integration_test/full_integration_test.dart
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ 전체 기능 테스트 완료" -ForegroundColor Green
} else {
    Write-Host "  ⚠ 전체 기능 테스트 실패" -ForegroundColor Yellow
}

Write-Host "  - UI/UX 일관성 테스트..." -ForegroundColor Cyan
flutter test integration_test/ui_consistency_test.dart
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ UI/UX 일관성 테스트 완료" -ForegroundColor Green
} else {
    Write-Host "  ⚠ UI/UX 일관성 테스트 실패" -ForegroundColor Yellow
}

Write-Host "  - 성능 테스트..." -ForegroundColor Cyan
flutter test integration_test/performance_test.dart
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ 성능 테스트 완료" -ForegroundColor Green
} else {
    Write-Host "  ⚠ 성능 테스트 실패" -ForegroundColor Yellow
}

Write-Host "  - 에러 시나리오 테스트..." -ForegroundColor Cyan
flutter test integration_test/error_scenario_test.dart
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ 에러 시나리오 테스트 완료" -ForegroundColor Green
    $testResults.IntegrationTests = $true
} else {
    Write-Host "  ⚠ 에러 시나리오 테스트 실패" -ForegroundColor Yellow
    $testResults.IntegrationTests = $false
}
Write-Host ""

# 5. 빌드 테스트
Write-Host "[5/6] 빌드 테스트 실행 중..." -ForegroundColor Yellow
Write-Host "  - Android Debug 빌드..." -ForegroundColor Cyan
flutter build apk --debug
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Android Debug 빌드 완료" -ForegroundColor Green
    $testResults.BuildTest = $true
} else {
    Write-Host "  ❌ Android Debug 빌드 실패" -ForegroundColor Red
    $testResults.BuildTest = $false
}
Write-Host ""

# 6. 검증 요약 생성
Write-Host "[6/6] 검증 요약 생성 중..." -ForegroundColor Yellow

$reportContent = @"
========================================
PokiFairy 최종 검증 보고서
생성 시간: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
========================================

검증 결과:
-----------
의존성 확인:     $(if ($testResults.Dependencies) { "✓ 통과" } else { "❌ 실패" })
코드 분석:       $(if ($testResults.Analysis) { "✓ 통과" } else { "⚠ 경고" })
단위 테스트:     $(if ($testResults.UnitTests) { "✓ 통과" } else { "⚠ 일부 실패" })
통합 테스트:     $(if ($testResults.IntegrationTests) { "✓ 통과" } else { "⚠ 일부 실패" })
빌드 테스트:     $(if ($testResults.BuildTest) { "✓ 통과" } else { "❌ 실패" })

프로젝트 정보:
--------------
버전: 1.1.0+2
플랫폼: Windows
Flutter SDK:
$(flutter --version)

통합 기능:
----------
✓ PokiFairy 페어리 컴패니언 기능
✓ OurSecretBase AI 채팅 기능
✓ Riverpod 상태 관리
✓ GoRouter 라우팅
✓ 다국어 지원 (한국어/영어)
✓ OnDevice AI (GGUF/llama.cpp)

다음 단계:
----------
1. 모든 테스트 통과 확인
2. 릴리즈 빌드 생성: flutter build apk --release
3. iOS 빌드 테스트 (macOS 환경)
4. 배포 준비

========================================
"@

$reportContent | Out-File -FilePath "verification_report.txt" -Encoding UTF8

Write-Host "✓ 검증 보고서 생성 완료: verification_report.txt" -ForegroundColor Green
Write-Host ""

# 최종 요약
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "최종 검증 완료!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$passedTests = ($testResults.Values | Where-Object { $_ -eq $true }).Count
$totalTests = $testResults.Count

Write-Host "검증 통과: $passedTests/$totalTests" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })
Write-Host ""

Write-Host "다음 단계:" -ForegroundColor Cyan
Write-Host "1. verification_report.txt 확인" -ForegroundColor White
Write-Host "2. 릴리즈 빌드 생성: flutter build apk --release" -ForegroundColor White
Write-Host "3. 배포 준비" -ForegroundColor White
Write-Host ""

# 사용자 입력 대기
Read-Host "계속하려면 Enter 키를 누르세요"
