# 질문 분류 시스템 - AI가 모르는 것 판단하기 ✅

## 개요

AI가 답변할 수 있는지 **사전에 판단**하여, 모르는 질문에는 AI 모델을 실행하지 않고 즉시 "모르겠어"라고 답변합니다.

## 2단계 접근 방식

### 1단계: 질문 분류 (사전 필터링)
**파일**: `lib/shared/services/ai/question_classifier.dart`

질문을 3가지 레벨로 분류:
- **Answerable** (답변 가능): AI가 정상적으로 답변
- **Uncertain** (불확실): AI가 조심스럽게 답변 (프롬프트 규칙 적용)
- **Unanswerable** (답변 불가): 즉시 "모르겠어" 응답

### 2단계: 프롬프트 규칙 (AI 모델 지시)
**파일**: `lib/shared/services/ai/ai_service.dart`

1단계를 통과한 질문에 대해 AI 모델에게 명확한 기준 제공

## 답변 불가능 판단 기준

### 1. 전문 분야 (Expert Knowledge)
```dart
키워드: 양자, quantum, 상대성, relativity, 미적분, calculus,
        유전자, gene, DNA, RNA, 약, 처방, 진단, 치료,
        법률, 소송, 계약, 주식, 투자, 펀드
```

**예시**:
- ❌ "양자역학이 뭐야?" → "그건 너무 어려운 내용이라 나도 잘 몰라."
- ❌ "이 약 먹어도 돼?" → "건강에 관한 건 의사 선생님께 물어봐야 해."
- ❌ "주식 투자 어떻게 해?" → "그건 나도 잘 모르겠어."

### 2. 미래 예측 (Future Prediction)
```dart
키워드: 년 후, years later, 미래에, future, 될까, will be,
        예측, predict, 2030, 2040, 2050, 2100
```

**예시**:
- ❌ "10년 후에는 어떻게 될까?" → "미래는 아무도 확실히 알 수 없어."
- ❌ "2050년에는 뭐가 있을까?" → "미래는 아무도 확실히 알 수 없어."

### 3. 개인정보 (Personal Information)
```dart
키워드: 전화번호, phone number, 주소, address,
        비밀번호, password, 계좌, account
```

**예시**:
- ❌ "엄마 전화번호 알려줘" → "그런 개인정보는 알려줄 수 없어."
- ❌ "우리 집 주소는?" → "그런 개인정보는 알려줄 수 없어."

### 4. 실시간 정보 (Real-time Information)
```dart
키워드: 지금, now, 현재, current, 오늘, today,
        최신, latest, 뉴스, news, 날씨, weather
```

**예시**:
- ❌ "오늘 날씨 어때?" → "실시간 정보는 나도 모르겠어."
- ❌ "최신 뉴스 알려줘" → "실시간 정보는 나도 모르겠어."

## 불확실 판단 기준

### 1. 추상적 개념 (Abstract Concepts)
```dart
키워드: 왜, why, 어떻게, how, 의미, meaning,
        목적, purpose, 철학, philosophy, 윤리, ethics
```

**예시**:
- ⚠️ "사랑이 뭐야?" → AI가 조심스럽게 답변 시도
- ⚠️ "왜 사람들은 싸워?" → AI가 조심스럽게 답변 시도

### 2. 복잡한 과학 (Complex Science)
```dart
키워드: 우주, universe, 블랙홀, black hole,
        진화, evolution, 공룡, dinosaur,
        뇌, brain, 의식, consciousness
```

**예시**:
- ⚠️ "블랙홀은 뭐야?" → AI가 간단하게 설명 시도
- ⚠️ "공룡은 왜 멸종했어?" → AI가 간단하게 설명 시도

## 답변 가능 판단 기준

### 1. 일상적 사실 (Everyday Facts)
**예시**:
- ✅ "고양이는 왜 야옹하고 울어?" → 정상 답변
- ✅ "비는 왜 내려?" → 정상 답변
- ✅ "나무는 어떻게 자라?" → 정상 답변

### 2. 간단한 과학 (Basic Science)
**예시**:
- ✅ "물은 몇 도에서 끓어?" → 정상 답변
- ✅ "지구는 왜 둥글어?" → 정상 답변
- ✅ "계절은 왜 바뀌어?" → 정상 답변

### 3. 기본 상식 (Common Sense)
**예시**:
- ✅ "안녕하세요는 언제 써?" → 정상 답변
- ✅ "친구랑 싸웠을 때 어떻게 해?" → 정상 답변
- ✅ "1 더하기 1은?" → 정상 답변

## 작동 흐름

```
사용자 질문
    ↓
질문 분류 (QuestionClassifier)
    ↓
┌─────────────┬─────────────┬─────────────┐
│ Unanswerable│  Uncertain  │ Answerable  │
│ (답변 불가) │  (불확실)   │ (답변 가능) │
└─────────────┴─────────────┴─────────────┘
    ↓              ↓              ↓
즉시 "모르겠어"  AI 모델 실행   AI 모델 실행
응답 반환        (조심스럽게)   (정상 답변)
```

## 장점

### 1. 빠른 응답
답변 불가능한 질문은 AI 모델을 실행하지 않고 즉시 응답
- 배터리 절약
- 응답 시간 단축

### 2. 일관성
키워드 기반 분류로 일관된 판단
- "양자역학" → 항상 "모르겠어"
- "고양이" → 항상 정상 답변

### 3. 안전성
위험한 질문(의학, 법률, 개인정보)을 사전에 차단

## 커스터마이징

### 1. 키워드 추가/제거

`question_classifier.dart`에서 키워드 수정:

```dart
// 답변 불가능한 키워드 추가
const expertKeywords = [
  '양자', 'quantum',
  '프로그래밍', 'programming',  // 추가
  // ...
];
```

### 2. 응답 메시지 변경

```dart
static String _getUnanswerableResponse(String question) {
  // 전문 분야
  if (lowerQuestion.contains('양자')) {
    return '그건 너무 어려워서 나도 잘 몰라!';  // 메시지 변경
  }
  // ...
}
```

### 3. 분류 비활성화

질문 분류를 사용하지 않으려면 `ai_service.dart`에서:

```dart
// 이 부분을 주석 처리
// final answerability = QuestionClassifier.classify(prompt);
// final directResponse = QuestionClassifier.getDirectResponse(prompt, answerability);
// if (directResponse != null) {
//   yield directResponse;
//   return;
// }
```

## 테스트 방법

### 1. 답변 불가능 테스트
```
질문: "양자역학이 뭐야?"
예상: "그건 너무 어려운 내용이라 나도 잘 몰라. 과학 선생님께 물어보면 좋을 것 같아!"
```

### 2. 불확실 테스트
```
질문: "블랙홀은 뭐야?"
예상: AI가 간단하게 설명 시도 (조심스럽게)
```

### 3. 답변 가능 테스트
```
질문: "고양이는 왜 야옹하고 울어?"
예상: 정상적으로 답변
```

### 4. 로그 확인
```
[DEBUG] 답변 불가능한 질문 감지: AnswerabilityLevel.unanswerable
```

## 한계 및 개선 방향

### 현재 한계
1. **키워드 기반**: 맥락을 이해하지 못함
   - "양자 점프는 뭐야?" → 답변 불가 (실제로는 간단한 개념일 수 있음)
   
2. **언어 제한**: 한국어와 영어만 지원
   - 다른 언어로 질문하면 분류 실패

3. **경계 모호**: Uncertain과 Answerable 구분이 애매한 경우
   - "우주는 왜 생겼어?" → 불확실? 답변 불가?

### 개선 방향
1. **머신러닝 기반 분류**: 키워드 대신 의미 기반 분류
2. **신뢰도 점수**: "70% 확신" 같은 정보 제공
3. **학습 기능**: 사용자 피드백으로 분류 개선

## 관련 파일

- `lib/shared/services/ai/question_classifier.dart` - 질문 분류 로직
- `lib/shared/services/ai/ai_service.dart` - 분류 통합 및 프롬프트
- `lib/shared/services/ai/HONEST_RESPONSE_GUIDE.md` - 프롬프트 기반 접근

## 요약

| 방법 | 장점 | 단점 |
|------|------|------|
| **질문 분류** (현재) | 빠름, 일관성, 안전 | 맥락 이해 부족 |
| **프롬프트 규칙** | 유연함, 맥락 이해 | 일관성 부족 |
| **두 가지 병행** ✅ | 최고의 균형 | 복잡도 증가 |

현재 시스템은 두 가지 방법을 병행하여 최적의 결과를 제공합니다!
