# Multi-Format AI Model Support

이 앱은 다양한 AI 모델 형식을 지원합니다.

## 지원하는 모델 형식

### 1. GGUF (llama.cpp) ⭐ 권장
- **확장자**: `.gguf`
- **엔진**: llama.cpp (FFI)
- **장점**:
  - 완전한 스트리밍 지원
  - 메모리 효율적 (양자화)
  - 다양한 LLM 지원 (Llama, Gemma, Phi, Qwen 등)
  - 오프라인 완전 지원
- **추천 모델**:
  - Gemma 2B/7B (Q4_K_M)
  - Phi-3 Mini (Q4_K_M)
  - Qwen 2.5 (Q4_K_M)

### 2. ONNX Runtime ⚠️ 실험적
- **확장자**: `.onnx`
- **엔진**: ONNX Runtime 1.4.1
- **장점**:
  - 크로스 플랫폼
  - 다양한 프레임워크 지원
- **제한사항**:
  - ⚠️ 현재 버전에서 LLM 추론 제한적
  - 토큰 타입 불일치 문제
  - 스트리밍 미지원
  - 토크나이저 별도 필요
- **권장**: GGUF로 변환 후 사용

### 3. TensorFlow Lite ⚠️ 실험적
- **확장자**: `.tflite`, `.lite`
- **엔진**: TFLite
- **장점**:
  - 모바일 최적화
  - GPU 가속
- **제한사항**:
  - ⚠️ LLM 추론에 제한적
  - 스트리밍 미지원
  - 토크나이저 별도 필요
- **권장**: GGUF로 변환 후 사용

## 모델 설치 방법

### Android

1. **파일 관리자로 복사**:
   ```
   /storage/emulated/0/Documents/AiModels/
   또는
   /sdcard/Documents/AiModels/
   ```

2. **ADB로 전송**:
   ```bash
   adb push model.gguf /sdcard/Documents/AiModels/
   ```

3. **앱 전용 폴더** (권장):
   ```
   Android/data/com.example.pokifairy/files/models/
   ```

### iOS

1. **Files 앱 사용**:
   - Files 앱 열기
   - "On My iPhone" → "PokiFairy" → "models"
   - 모델 파일 복사

2. **iTunes/Finder로 전송**:
   - 기기 연결
   - 파일 공유 섹션에서 앱 선택
   - 모델 파일 드래그 앤 드롭

## 모델 다운로드

### GGUF 모델
- **Hugging Face**: https://huggingface.co/models?library=gguf
- **추천 저장소**:
  - `TheBloke` - 다양한 양자화 모델
  - `bartowski` - 최신 모델 양자화
  - `QuantFactory` - 고품질 양자화

### ONNX 모델
- **Hugging Face**: https://huggingface.co/models?library=onnx
- **ONNX Model Zoo**: https://github.com/onnx/models

**⚠️ 중요**: ONNX 모델이 큰 경우 두 파일로 분리됩니다:
- `model.onnx` - 메타데이터 (작은 파일)
- `model.onnx.data` - 가중치 (큰 파일)

**두 파일을 모두 같은 폴더에 넣어야 합니다!**

### TFLite 모델
- **TensorFlow Hub**: https://tfhub.dev/
- **Hugging Face**: https://huggingface.co/models?library=tf-lite

## ONNX 모델 파일 구조

### 작은 모델 (< 2GB)
```
model.onnx  (단일 파일)
```

### 큰 모델 (> 2GB)
```
model.onnx       (10-50MB - 메타데이터, 그래프 구조)
model.onnx.data  (2-10GB - 가중치 데이터)
```

### 배치 방법
1. **두 파일을 모두** AiModels 폴더에 복사
2. 앱에서 **model.onnx만 선택**
3. ONNX Runtime이 자동으로 .data 파일 찾음

### 예시
```bash
# ADB로 전송
adb push gemma-2b.onnx /sdcard/Documents/AiModels/
adb push gemma-2b.onnx.data /sdcard/Documents/AiModels/

# 결과
/sdcard/Documents/AiModels/
├── gemma-2b.onnx       ← 앱에서 이것만 선택
└── gemma-2b.onnx.data  ← 자동으로 로드됨
```

## 사용 예시

### 1. 모델 자동 감지
```dart
// 모델 형식 자동 감지
final format = await ModelFactory.detectFormat(modelPath);
print('감지된 형식: ${ModelFactory.getFormatName(format)}');

// 적절한 엔진 자동 생성
final engine = await ModelFactory.createEngine(modelPath);
await engine.loadModel(modelPath);
```

### 2. 특정 엔진 직접 사용
```dart
// GGUF
final ggufEngine = GGUFInferenceEngine();
await ggufEngine.loadModel('model.gguf');

// ONNX
final onnxEngine = ONNXInferenceEngine();
await onnxEngine.loadModel('model.onnx');

// TFLite
final tfliteEngine = TFLiteInferenceEngine();
await tfliteEngine.loadModel('model.tflite');
```

### 3. 스트리밍 생성
```dart
await for (final chunk in engine.generateStream('안녕하세요')) {
  print(chunk);
}
```

## 성능 비교

| 형식 | 메모리 | 속도 | 스트리밍 | 모델 선택 |
|------|--------|------|----------|-----------|
| GGUF | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| ONNX | ⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| TFLite | ⭐⭐⭐ | ⭐⭐ | ⭐ | ⭐⭐ |

## 권장 사항

### 일반 사용자 ⭐
- **GGUF 형식 강력 권장**
- 이유: 
  - ✅ 완전한 스트리밍
  - ✅ 토크나이저 내장
  - ✅ 다양한 모델 지원
  - ✅ 메모리 효율적
  - ✅ 안정적인 추론

### ONNX/TFLite 사용자
- ⚠️ 현재 버전에서는 제한적
- **권장 워크플로우**:
  ```
  ONNX/TFLite 모델 보유
       ↓
  GGUF로 변환 (llama.cpp)
       ↓
  앱에서 완전한 기능 사용 ✅
  ```

### 개발자
- **LLM 채팅**: GGUF만 사용
- **이미지 분류**: TFLite 가능
- **객체 감지**: ONNX/TFLite 가능
- **텍스트 생성**: GGUF만 권장

## 자동 샘플링 전략 (GGUF 전용) ⭐

앱이 **질문 유형을 자동으로 감지**하여 최적의 샘플링 파라미터를 선택합니다!

### 질문 유형별 자동 설정

#### 🎨 창의적 질문
**감지 키워드**: 이야기, 상상, 만들어, 동화, 모험, 마법
```
예: "재미있는 이야기를 들려줘"
→ Temperature: 1.2 (높음)
→ 다양하고 창의적인 응답
```

#### 📚 사실적 질문
**감지 키워드**: 뭐야, 설명, 알려줘, 방법, 이유, 계산
```
예: "공룡은 왜 멸종했어?"
→ Temperature: 0.5 (낮음)
→ 정확하고 일관된 응답
```

#### 💬 대화형 질문
**감지 키워드**: 안녕, 좋아, 어때, 생각, 기분, 오늘
```
예: "오늘 기분이 어때?"
→ Temperature: 0.9 (중간)
→ 자연스러운 대화
```

#### ❓ 일반 질문
**기타 모든 질문**
```
→ Temperature: 0.8 (균형)
→ 균형잡힌 응답
```

### 작동 방식
```
사용자 질문 입력
    ↓
질문 유형 자동 감지
    ↓
최적 파라미터 선택
    ↓
AI 응답 생성
```

## 샘플링 파라미터 상세 (GGUF 전용)

### Temperature (온도)
- **범위**: 0.1 ~ 2.0
- **자동 설정**: 0.5 ~ 1.2
- **효과**:
  - 낮음 (0.5): 결정적, 반복적, 안전한 응답
  - 중간 (0.8): 균형잡힌 응답 ⭐ 기본값
  - 높음 (1.2): 창의적, 다양한, 예측 불가능

### Top-K
- **범위**: 1 ~ 100
- **권장**: 40
- **효과**: 상위 K개 토큰만 고려 (다양성 제어)

### Top-P (Nucleus Sampling)
- **범위**: 0.1 ~ 1.0
- **권장**: 0.95
- **효과**: 누적 확률이 P에 도달할 때까지 토큰 고려

### Repeat Penalty (반복 패널티)
- **범위**: 1.0 ~ 1.5
- **권장**: 1.1
- **효과**: 최근 토큰 반복 억제 (높을수록 강함)

### 자동 전략 예시

```dart
// 자동 감지 (권장) ⭐
final params = SamplingStrategy.selectParams(prompt);
generateTextStream(prompt,
  temperature: params.temperature,
  topK: params.topK,
  topP: params.topP,
  repeatPenalty: params.repeatPenalty,
);

// 수동 설정 (고급 사용자)
generateTextStream(prompt,
  temperature: 0.8,
  topK: 40,
  topP: 0.95,
  repeatPenalty: 1.1,
);
```

### 질문 예시별 자동 설정

| 질문 | 감지 유형 | Temperature | 설명 |
|------|-----------|-------------|------|
| "재미있는 이야기 들려줘" | 창의적 | 1.2 | 다양한 이야기 |
| "공룡은 왜 멸종했어?" | 사실적 | 0.5 | 정확한 설명 |
| "오늘 기분 어때?" | 대화형 | 0.9 | 자연스러운 대화 |
| "도와줘" | 일반 | 0.8 | 균형잡힌 응답 |

## 특수 명령어

채팅에서 다음 명령어를 입력하면 특별한 기능을 사용할 수 있습니다:

### 모델 정보 확인
다음 중 하나를 입력하세요:
- `/model`
- `/모델`
- `모델 정보`
- `현재 모델`

**출력 예시**:
```
🤖 현재 AI 모델 정보

━━━━━━━━━━━━━━━━━━━━━━
📁 모델: gemma-2b-it-Q4_K_M.gguf
🔧 형식: GGUF (llama.cpp)
💾 크기: 1.6GB
✅ 상태: 로드됨 (사용 가능)
⏱️ 로드 시간: 0시간 15분 전
🔋 배터리 최적화: 활성화
━━━━━━━━━━━━━━━━━━━━━━

💡 팁: 모델을 변경하려면 설정 버튼을 눌러주세요!
```

**사용 시나리오**:
- ✅ 모델 변경 후 제대로 적용되었는지 확인
- ✅ 현재 사용 중인 모델 파일명 확인
- ✅ 모델 크기 및 형식 확인
- ✅ 로드 상태 확인

## 문제 해결

### 자문자답 (질문: ... 답변: ...)
**원인**: 모델이 대화 형식을 학습하여 계속 생성
**해결**:
1. ✅ 자동 감지 및 중단 (이미 구현됨)
   - "질문:", "답변:", "Q:", "A:" 등 감지
   - 패턴 발견 시 즉시 중단
2. 다른 모델 사용 (instruction-tuned 모델 권장)
3. 프롬프트 형식 개선 (이미 적용됨)

### 반복적인 응답
1. **Temperature 높이기**: 0.8 → 1.0
2. **Repeat Penalty 높이기**: 1.1 → 1.3
3. **Top-K 늘리기**: 40 → 60
4. 더 큰 모델 사용 (2B → 7B)

### 모델이 감지되지 않음
1. 저장소 권한 확인
2. 파일 경로 확인
3. 파일 확장자 확인 (`.gguf`, `.onnx`, `.tflite`)

### 메모리 부족
1. 더 작은 모델 사용 (2B 대신 1B)
2. 양자화 수준 높이기 (Q4 대신 Q3)
3. 다른 앱 종료

### 느린 추론 속도
1. 양자화된 모델 사용
2. GPU 가속 활성화 (ONNX, TFLite)
3. 스레드 수 조정
4. Temperature 낮추기 (계산 간소화)

## 라이선스

- llama.cpp: MIT License
- ONNX Runtime: MIT License
- TensorFlow Lite: Apache 2.0 License
