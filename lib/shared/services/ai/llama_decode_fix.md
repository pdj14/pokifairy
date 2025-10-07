# llama_decode 실패 (코드:1) 해결 방법

## 문제 원인
`llama_decode` 실패 코드 1은 다음 원인들로 발생합니다:

1. **컨텍스트 파라미터 미설정** - nCtx, nBatch가 기본값으로 설정되어 있음
2. **프롬프트 길이 초과** - 프롬프트 토큰 수가 컨텍스트 크기를 초과
3. **배치 logits 설정 오류** - 모든 청크에서 logits를 계산하려고 시도
4. **청크 크기가 너무 작음** - 32 토큰씩 처리하면 오버헤드가 큼

## 해결 방법

### 1. 컨텍스트 파라미터 명시적 설정
`native_bindings.dart`의 `loadModel` 메서드에서:

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

### 2. 프롬프트 길이 검증 추가
`generateTextStream` 메서드에서 토큰화 후:

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

### 3. 청크 크기 증가 및 logits 설정 수정

```dart
const int chunkSize = 128; // 32 -> 128로 증가

// 마지막 청크의 마지막 토큰만 logits 계산
if (batch.logits != nullptr) {
  final isLastChunk = (processed + cur >= tokenCount);
  for (int i = 0; i < cur; i++) {
    batch.logits[i] = (isLastChunk && i == cur - 1) ? 1 : 0;
  }
}
```

### 4. 더 나은 에러 메시지

```dart
if (dr != 0) {
  print('❌ llama_decode 실패 (코드:$dr) - 위치: $processed/$tokenCount');
  print('   컨텍스트 크기: $ctxSize, 청크 크기: $cur');
  allTokensProcessed = false;
  lastDecodeResult = dr;
  break;
}
```

## 적용 방법

1. `native_bindings.dart` 파일을 열기
2. 위의 수정사항들을 해당 위치에 적용
3. 앱 재시작

## 추가 디버깅

만약 여전히 문제가 발생한다면:
- 로그에서 "컨텍스트 크기"와 "프롬프트 토큰 수" 확인
- 프롬프트를 더 짧게 만들어 테스트
- 모델 파일이 손상되지 않았는지 확인
