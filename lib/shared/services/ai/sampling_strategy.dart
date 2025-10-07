/// AI 샘플링 전략
/// 
/// 질문 유형에 따라 최적의 샘플링 파라미터를 자동으로 선택합니다.

/// 샘플링 파라미터 세트
class SamplingParams {
  final double temperature;
  final int topK;
  final double topP;
  final double repeatPenalty;
  final String description;

  const SamplingParams({
    required this.temperature,
    required this.topK,
    required this.topP,
    required this.repeatPenalty,
    required this.description,
  });

  /// 균형잡힌 기본 설정 (초등학생용 - 간결)
  static const balanced = SamplingParams(
    temperature: 0.7,
    topK: 30,
    topP: 0.92,
    repeatPenalty: 1.2,
    description: '균형잡힌 짧은 답변',
  );

  /// 창의적 응답 (이야기, 상상력)
  static const creative = SamplingParams(
    temperature: 1.0,
    topK: 50,
    topP: 0.95,
    repeatPenalty: 1.15,
    description: '창의적이지만 간결한 답변',
  );

  /// 정확한 응답 (사실, 계산, 설명)
  static const precise = SamplingParams(
    temperature: 0.5,
    topK: 20,
    topP: 0.9,
    repeatPenalty: 1.1,
    description: '정확하고 짧은 답변',
  );

  /// 대화형 응답 (일상 대화)
  static const conversational = SamplingParams(
    temperature: 0.8,
    topK: 40,
    topP: 0.93,
    repeatPenalty: 1.2,
    description: '자연스럽고 짧은 대화',
  );
}

/// 질문 유형
enum QuestionType {
  creative,      // 창의적 (이야기, 상상)
  factual,       // 사실적 (정보, 설명)
  conversational, // 대화형 (인사, 잡담)
  unknown,       // 알 수 없음
}

/// 샘플링 전략 선택기
class SamplingStrategy {
  /// 질문 유형 감지
  static QuestionType detectQuestionType(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    // 창의적 질문 키워드
    const creativeKeywords = [
      '이야기', '상상', '만들어', '창작', '꿈', '모험',
      '동화', '재미있는', '신기한', '마법', '판타지',
      '어떻게 될까', '만약에', '가정', '상상해',
      'story', 'imagine', 'create', 'fantasy',
    ];
    
    // 사실적 질문 키워드
    const factualKeywords = [
      '뭐야', '무엇', '어떻게', '왜', '설명', '알려줘',
      '가르쳐', '방법', '이유', '원리', '계산', '정의',
      'what', 'how', 'why', 'explain', 'define', 'calculate',
    ];
    
    // 대화형 질문 키워드
    const conversationalKeywords = [
      '안녕', '반가워', '좋아', '싫어', '어때', '생각',
      '느낌', '기분', '오늘', '요즘', '최근',
      'hello', 'hi', 'how are you', 'what do you think',
    ];
    
    // 키워드 매칭
    int creativeScore = 0;
    int factualScore = 0;
    int conversationalScore = 0;
    
    for (final keyword in creativeKeywords) {
      if (lowerPrompt.contains(keyword)) creativeScore++;
    }
    
    for (final keyword in factualKeywords) {
      if (lowerPrompt.contains(keyword)) factualScore++;
    }
    
    for (final keyword in conversationalKeywords) {
      if (lowerPrompt.contains(keyword)) conversationalScore++;
    }
    
    // 가장 높은 점수의 유형 선택
    if (creativeScore > factualScore && creativeScore > conversationalScore) {
      return QuestionType.creative;
    } else if (factualScore > conversationalScore) {
      return QuestionType.factual;
    } else if (conversationalScore > 0) {
      return QuestionType.conversational;
    }
    
    // 질문 길이로 추가 판단
    if (prompt.length > 100) {
      return QuestionType.creative; // 긴 질문은 보통 창의적
    } else if (prompt.contains('?')) {
      return QuestionType.factual; // 물음표가 있으면 사실적
    }
    
    return QuestionType.unknown;
  }
  
  /// 질문 유형에 따른 최적 샘플링 파라미터 선택
  static SamplingParams selectParams(String prompt) {
    final questionType = detectQuestionType(prompt);
    
    switch (questionType) {
      case QuestionType.creative:
        print('🎨 창의적 질문 감지 → 창의적 샘플링');
        return SamplingParams.creative;
      
      case QuestionType.factual:
        print('📚 사실적 질문 감지 → 정확한 샘플링');
        return SamplingParams.precise;
      
      case QuestionType.conversational:
        print('💬 대화형 질문 감지 → 대화형 샘플링');
        return SamplingParams.conversational;
      
      case QuestionType.unknown:
        print('❓ 일반 질문 → 균형잡힌 샘플링');
        return SamplingParams.balanced;
    }
  }
  
  /// 디버그: 질문 분석 결과 출력
  static void analyzeQuestion(String prompt) {
    final questionType = detectQuestionType(prompt);
    final params = selectParams(prompt);
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📝 질문: ${prompt.length > 50 ? prompt.substring(0, 50) + "..." : prompt}');
    print('🔍 감지된 유형: $questionType');
    print('⚙️  선택된 전략: ${params.description}');
    print('   - Temperature: ${params.temperature}');
    print('   - Top-K: ${params.topK}');
    print('   - Top-P: ${params.topP}');
    print('   - Repeat Penalty: ${params.repeatPenalty}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
