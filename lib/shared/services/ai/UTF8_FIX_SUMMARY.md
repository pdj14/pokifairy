# UTF-16 인코딩 오류 수정 완료 ✅

## 문제 설명

### 오류 메시지
```
ArgumentError: Invalid argument(s): string is not well-formed UTF-16
```

### 증상
- AI 응답에 "�" 같은 잘못된 문자 표시
- Flutter UI에서 텍스트 렌더링 실패
- 로그: `1차 루프 완료 후 남은 텍스트 전송: "�️"`

### 원인
llama.cpp에서 생성된 토큰을 UTF-8로 디코딩할 때, 불완전한 바이트 시퀀스를 `allowMalformed: true`로 처리하여 잘못된 문자(�)가 생성됨.

## 적용된 수정사항

### 1. ✅ 안전한 UTF-8 디코딩 로직 구현

**기존 코드** (문제):
```dart
final bytes = outBuf.asTypedList(wrote);
currentText = utf8.decode(bytes, allowMalformed: true); // ❌ 잘못된 문자 생성
```

**수정 후** (해결):
```dart
final bytes = outBuf.asTypedList(wrote);

// UTF-8 디코딩 시 불완전한 문자 처리
String decodedText;
try {
  decodedText = utf8.decode(bytes, allowMalformed: false);
} catch (e) {
  // 불완전한 UTF-8 시퀀스가 있으면 마지막 몇 바이트를 제외하고 디코딩
  int validLength = bytes.length;
  while (validLength > 0) {
    try {
      decodedText = utf8.decode(bytes.sublist(0, validLength), allowMalformed: false);
      break;
    } catch (_) {
      validLength--;
    }
  }
  if (validLength == 0) {
    // 디코딩 가능한 바이트가 없으면 스킵
    malloc.free(outBuf);
    malloc.free(genPtr);
    continue; // 또는 return
  }
  decodedText = utf8.decode(bytes.sublist(0, validLength), allowMalformed: false);
}

currentText = decodedText;
```

### 2. ✅ 잘못된 문자 필터링 추가

```dart
// 유효한 텍스트만 전송 (제어 문자 제외)
if (remainingText.trim().isNotEmpty && !remainingText.contains('�')) {
  print('1차 루프 완료 후 남은 텍스트 전송: "$remainingText"');
  yield remainingText;
  lastYieldedLength = currentText.length;
}
```

### 3. ✅ 모든 디코딩 위치에 적용

수정된 위치:
1. `generateTextStream()` - 1차 루프 스트리밍
2. `generateTextStream()` - 1차 루프 완료 후
3. `generateTextStream()` - 자동 이어쓰기 루프
4. `generateText()` - 최종 응답 생성

## 작동 원리

### UTF-8 멀티바이트 문자
한글과 이모지는 여러 바이트로 구성됩니다:
- 한글: 3바이트 (예: "안" = 0xEC 0x95 0x88)
- 이모지: 4바이트 (예: "😊" = 0xF0 0x9F 0x98 0x8A)

### 문제 발생 시나리오
1. llama.cpp가 토큰을 생성
2. 토큰을 바이트로 변환
3. **마지막 문자가 불완전한 경우** (예: 3바이트 중 2바이트만 있음)
4. `allowMalformed: true` → "�" 생성 ❌
5. Flutter UI에서 렌더링 실패

### 수정된 로직
1. llama.cpp가 토큰을 생성
2. 토큰을 바이트로 변환
3. **엄격한 UTF-8 디코딩 시도** (`allowMalformed: false`)
4. 실패 시 → 뒤에서부터 바이트를 하나씩 제거하며 재시도
5. 유효한 부분만 디코딩 ✅
6. 불완전한 부분은 다음 스트리밍에서 처리

## 테스트 방법

### 1. 앱 재시작
```bash
flutter run -d <device_id>
```

### 2. 다양한 문자 테스트
- 한글: "안녕하세요"
- 영어: "Hello"
- 이모지: "😊🎉"
- 혼합: "안녕 Hello 😊"

### 3. 로그 확인
정상 로그:
```
스트리밍: 토큰 463 추가, 총 생성된 토큰: 17
1차 루프 완료 후 남은 텍스트 전송: "안녕하세요"  ✅
```

오류 로그 (수정 전):
```
1차 루프 완료 후 남은 텍스트 전송: "�️"  ❌
ArgumentError: Invalid argument(s): string is not well-formed UTF-16
```

## 추가 개선사항

### 1. 디버깅 로그 추가
불완전한 UTF-8 시퀀스 감지 시 로그 출력:
```dart
} catch (e) {
  print('⚠️ 불완전한 UTF-8 시퀀스 감지, 유효한 부분만 디코딩');
  // ... 처리 로직
}
```

### 2. 성능 최적화
- 유효하지 않은 바이트는 즉시 스킵
- 불필요한 메모리 할당 방지

## 관련 파일

- `lib/shared/services/ai/native_bindings.dart` - 모든 UTF-8 디코딩 로직

## 참고 자료

- UTF-8 인코딩: https://en.wikipedia.org/wiki/UTF-8
- Dart UTF-8 디코딩: https://api.dart.dev/stable/dart-convert/Utf8Decoder-class.html
- Flutter 텍스트 렌더링: https://api.flutter.dev/flutter/painting/TextSpan-class.html
