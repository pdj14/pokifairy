# llama_decode 실패 (코드:1) 수정 완료 ✅

## 적용된 수정사항

### 1. ✅ 컨텍스트 파라미터 명시적 설정
**파일**: `native_bindings.dart` - `loadModel()` 메서드

```dart
// 컨텍스트 초기화 (params를 by-value로 전달)
final contextParams = _llamaContextDefaultParams();
// 안전한 컨텍스트 크기 설정
contextParams.nCtx = 2048;  // 컨텍스트 크기
contextParams.nBatch = 512; // 배치 크기 (nCtx보다 작아야 함)
contextParams.nUbatch = 128; // 물리적 배치 크기
contextParams.nThreads = 4; // 스레드 수
_context = _llamaInitFromModel(_model!, contextParams);
```

**효과**: llama.cpp가 적절한 메모리를 할당하고 배치 처리를 올바르게 수행

### 2. ✅ 프롬프트 길이 검증 추가
**파일**: `native_bindings.dart` - `generateTextStream()` 메서드

```dart
// 컨텍스트 크기 확인
final ctxSize = _llamaNCtx(_context!);
print('컨텍스트 크기: $ctxSize, 프롬프트 토큰 수: $tokenCount');

// 프롬프트가 컨텍스트 크기를 초과하는지 확인
if (tokenCount >= ctxSize - 64) {
  malloc.free(promptPtr);
  malloc.free(tokens);
  yield '⚠️ 프롬프트가 너무 깁니다 (토큰: $tokenCount, 최대: ${ctxSize - 64}).\n더 짧게 입력해주세요.';
  return;
}
```

**효과**: 프롬프트가 너무 길 경우 사용자에게 명확한 메시지 제공

### 3. ✅ 청크 크기 증가
**변경**: `const int chunkSize = 32;` → `const int chunkSize = 128;`

**효과**: 
- 더 효율적인 배치 처리
- 오버헤드 감소
- 처리 속도 향상

### 4. ✅ Logits 설정 최적화
```dart
// 마지막 청크의 마지막 토큰만 logits 계산
if (batch.logits != nullptr) {
  final isLastChunk = (processed + cur >= tokenCount);
  for (int i = 0; i < cur; i++) {
    batch.logits[i] = (isLastChunk && i == cur - 1) ? 1 : 0;
  }
}
```

**효과**: 
- 불필요한 logits 계산 방지
- 메모리 효율성 향상
- llama_decode 오류 가능성 감소

### 5. ✅ 에러 메시지 개선
```dart
if (dr != 0) {
  print('❌ llama_decode 실패 (코드:$dr) - 위치: $processed/$tokenCount');
  print('   컨텍스트 크기: $ctxSize, 청크 크기: $cur');
  allTokensProcessed = false;
  lastDecodeResult = dr;
  break;
}
```

**효과**: 디버깅 시 더 많은 정보 제공

## 다음 단계

### 1. 앱 재시작 (필수!)
FFI 변경사항은 hot reload로 적용되지 않습니다.
```bash
# 앱을 완전히 종료하고 다시 실행
flutter run -d <device_id>
```

### 2. 테스트
- 짧은 프롬프트부터 시작 (예: "안녕")
- 로그에서 다음 정보 확인:
  - `컨텍스트 크기: 2048, 프롬프트 토큰 수: X`
  - `llama_decode 호출 (청크: X~Y/총토큰수)`
- 정상 작동 확인 후 더 긴 프롬프트 테스트

### 3. 로그 확인
콘솔에서 다음 메시지들을 확인하세요:
- ✅ `컨텍스트 크기: 2048` - 올바르게 설정됨
- ✅ `llama_decode 호출 (청크: 0~127/X)` - 128 토큰씩 처리
- ✅ `모든 토큰 처리 시뮬레이션 완료` - 프롬프트 처리 성공

## 문제가 계속되는 경우

### 시나리오 1: 여전히 "llama_decode 실패 (코드:1)" 발생
**원인**: 프롬프트가 여전히 너무 길거나 시스템 프롬프트가 큼

**해결책**:
1. 로그에서 "프롬프트 토큰 수" 확인
2. `ai_service.dart`의 `_makeChildFriendlyPrompt()` 메서드에서 시스템 프롬프트 단축
3. 사용자 입력을 더 짧게 제한

### 시나리오 2: "프롬프트가 너무 깁니다" 메시지 표시
**원인**: 프롬프트 토큰 수가 1984개 이상 (2048 - 64)

**해결책**:
1. 시스템 프롬프트 길이 줄이기
2. 사용자 입력 길이 제한 추가
3. 필요시 nCtx를 4096으로 증가 (메모리 허용 시)

### 시나리오 3: 메모리 부족 오류
**원인**: 디바이스 메모리 부족

**해결책**:
1. 다른 앱 종료
2. 더 작은 모델 사용
3. nCtx를 1024로 감소

## 기술적 배경

### llama_decode 실패 코드 1의 의미
- **코드 1**: 일반적인 디코딩 오류
- 주요 원인:
  - KV 캐시 슬롯 부족
  - 배치 크기가 컨텍스트 크기 초과
  - Logits 설정 오류
  - 메모리 부족

### 수정이 작동하는 이유
1. **명시적 컨텍스트 설정**: llama.cpp가 충분한 메모리 할당
2. **프롬프트 검증**: 오버플로우 사전 방지
3. **큰 청크 크기**: 배치 처리 효율성 향상
4. **최적화된 logits**: 마지막 토큰만 계산하여 메모리 절약

## 참고 자료
- llama.cpp 문서: https://github.com/ggerganov/llama.cpp
- GGUF 형식: https://github.com/ggerganov/ggml/blob/master/docs/gguf.md
