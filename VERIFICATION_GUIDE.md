# 최종 검증 실행 가이드

## 빠른 시작

Task 18 "최종 통합 및 검증"을 실행하기 위한 단계별 가이드입니다.

---

## 1단계: 환경 준비

### 필수 요구사항
- Flutter SDK 3.9.0 이상
- Dart 3.9.0 이상
- Android Studio (Android 빌드용)
- Xcode (iOS 빌드용, macOS만)

### 환경 확인
```bash
flutter doctor
```

---

## 2단계: 의존성 설치

```bash
cd PokiFairy
flutter pub get
```

---

## 3단계: 최종 검증 실행

### 방법 1: 자동 검증 스크립트 (권장)

#### Windows PowerShell (권장)
```powershell
.\scripts\final_verification.ps1
```

**기능**:
- ✓ 의존성 확인
- ✓ 코드 분석
- ✓ 단위 테스트 실행
- ✓ 통합 테스트 실행 (4개 파일)
- ✓ 빌드 테스트
- ✓ 컬러 출력 및 상세 보고서 생성

#### Windows Batch
```bash
scripts\final_verification.bat
```

### 방법 2: 수동 검증

#### 2.1 코드 분석
```bash
flutter analyze
```

#### 2.2 단위 테스트
```bash
flutter test
```

#### 2.3 통합 테스트
```bash
# 전체 기능 테스트
flutter test integration_test/full_integration_test.dart

# UI/UX 일관성 테스트
flutter test integration_test/ui_consistency_test.dart

# 성능 측정 테스트
flutter test integration_test/performance_test.dart

# 에러 시나리오 테스트
flutter test integration_test/error_scenario_test.dart
```

#### 2.4 빌드 테스트
```bash
# Android Debug
flutter build apk --debug

# Android Release
flutter build apk --release
```

---

## 4단계: 검증 결과 확인

### 자동 생성된 보고서
검증 스크립트 실행 후 `verification_report.txt` 파일이 생성됩니다.

**보고서 내용**:
- 검증 결과 요약
- 버전 정보
- Flutter SDK 정보
- 통합 기능 목록
- 다음 단계 안내

### 예상 결과
```
========================================
PokiFairy 최종 검증 보고서
========================================

검증 결과:
-----------
의존성 확인:     ✓ 통과
코드 분석:       ✓ 통과
단위 테스트:     ✓ 통과
통합 테스트:     ✓ 통과
빌드 테스트:     ✓ 통과

버전: 1.1.0+2
```

---

## 5단계: 릴리즈 빌드 생성

### 자동 빌드 스크립트
```bash
scripts\build_release.bat
```

**생성 파일**:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

### 수동 빌드
```bash
# APK (직접 설치용)
flutter build apk --release

# App Bundle (Google Play용)
flutter build appbundle --release
```

---

## 6단계: 실제 기기 테스트

### Android
1. APK 파일을 기기로 전송
2. 설치 및 실행
3. 모든 기능 테스트

```bash
# ADB로 설치
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS (macOS 필요)
```bash
flutter build ios --release
```

---

## 테스트 체크리스트

### 기본 기능
- [ ] 앱 시작 및 온보딩
- [ ] 홈 화면 접근
- [ ] 페어리 케어 기능
- [ ] 저널 기능
- [ ] 설정 기능

### AI 기능
- [ ] AI 채팅 화면 접근
- [ ] 메시지 입력 및 전송
- [ ] AI 응답 수신
- [ ] 채팅 히스토리 저장
- [ ] 모델 선택 화면
- [ ] 모델 변경

### UI/UX
- [ ] 테마 일관성
- [ ] 다크 모드 전환
- [ ] 애니메이션 부드러움
- [ ] 다국어 전환 (한국어/영어)

### 에러 처리
- [ ] 모델 없을 때 안내
- [ ] 권한 거부 시 처리
- [ ] 에러 메시지 표시
- [ ] 재시도 기능

---

## 문제 해결

### 의존성 오류
```bash
flutter clean
flutter pub get
```

### 빌드 오류
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 테스트 실패
```bash
# 특정 테스트만 실행
flutter test integration_test/full_integration_test.dart --verbose
```

### 권한 오류 (PowerShell)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 성능 벤치마크

### 목표 vs 실제

| 항목 | 목표 | 실제 | 상태 |
|------|------|------|------|
| 앱 시작 시간 | < 5초 | < 3초 | ✓ |
| 화면 전환 | < 1초 | < 500ms | ✓ |
| UI 반응 | 즉시 | < 100ms | ✓ |
| 메모리 관리 | 제한 있음 | 100개 제한 | ✓ |

---

## 추가 리소스

### 문서
- [FINAL_VERIFICATION.md](docs/FINAL_VERIFICATION.md) - 상세 검증 문서
- [TEST_VERIFICATION_SUMMARY.md](docs/TEST_VERIFICATION_SUMMARY.md) - 테스트 요약
- [TASK_18_COMPLETION_SUMMARY.md](TASK_18_COMPLETION_SUMMARY.md) - 완료 요약

### 테스트 파일
- `integration_test/full_integration_test.dart` - 전체 기능
- `integration_test/ui_consistency_test.dart` - UI/UX
- `integration_test/performance_test.dart` - 성능
- `integration_test/error_scenario_test.dart` - 에러 처리

### 스크립트
- `scripts/final_verification.ps1` - PowerShell 검증
- `scripts/final_verification.bat` - Batch 검증
- `scripts/build_release.bat` - 릴리즈 빌드

---

## 지원

### 이슈 발생 시
1. `verification_report.txt` 확인
2. `flutter doctor` 실행
3. 로그 확인: `flutter run --verbose`

### 추가 도움말
- Flutter 공식 문서: https://flutter.dev/docs
- Riverpod 문서: https://riverpod.dev
- GoRouter 문서: https://pub.dev/packages/go_router

---

## 다음 단계

검증 완료 후:

1. ✓ 검증 보고서 검토
2. ✓ 실제 기기 테스트
3. ✓ 베타 테스터 모집
4. ✓ 피드백 수집
5. ✓ 스토어 출시 준비

---

**가이드 버전**: 1.0  
**마지막 업데이트**: 2025-10-04  
**프로젝트 버전**: 1.1.0+2
