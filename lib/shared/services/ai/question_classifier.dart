/// 질문 분류 및 답변 가능 여부 판단
/// 
/// AI가 답변할 수 있는지 사전에 판단하여
/// 모르는 질문에는 즉시 "모르겠어"라고 답변합니다.

enum AnswerabilityLevel {
  answerable,      // 답변 가능
  uncertain,       // 불확실 (조심스럽게 답변)
  unanswerable,    // 답변 불가 (모른다고 답변)
}

class QuestionClassifier {
  /// 질문의 답변 가능 여부 판단
  static AnswerabilityLevel classify(String question) {
    final lowerQuestion = question.toLowerCase();
    
    // 1. 명확히 답변 불가능한 질문들
    if (_isUnanswerable(lowerQuestion)) {
      return AnswerabilityLevel.unanswerable;
    }
    
    // 2. 불확실한 질문들
    if (_isUncertain(lowerQuestion)) {
      return AnswerabilityLevel.uncertain;
    }
    
    // 3. 답변 가능한 질문들
    return AnswerabilityLevel.answerable;
  }
  
  /// 답변 불가능한 질문 패턴
  static bool _isUnanswerable(String question) {
    // 전문 분야 키워드
    const expertKeywords = [
      '양자', 'quantum', '상대성', 'relativity',
      '미적분', 'calculus', '미분', '적분',
      '유전자', 'gene', 'dna', 'rna',
      '약', '처방', '진단', '치료', 'medicine',
      '법률', '소송', '계약', 'legal', 'law',
      '주식', '투자', '펀드', 'stock', 'investment',
    ];
    
    // 미래 예측 키워드
    const futureKeywords = [
      '년 후', 'years later', '미래에', 'future',
      '될까', 'will be', '예측', 'predict',
      '2030', '2040', '2050', '2100',
    ];
    
    // 개인정보 키워드
    const personalKeywords = [
      '전화번호', 'phone number', '주소', 'address',
      '비밀번호', 'password', '계좌', 'account',
    ];
    
    // 실시간 정보 키워드
    const realtimeKeywords = [
      '지금', 'now', '현재', 'current',
      '오늘', 'today', '최신', 'latest',
      '뉴스', 'news', '날씨', 'weather',
    ];
    
    // 키워드 매칭
    for (final keyword in [...expertKeywords, ...futureKeywords, ...personalKeywords, ...realtimeKeywords]) {
      if (question.contains(keyword)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 불확실한 질문 패턴
  static bool _isUncertain(String question) {
    // 추상적 개념
    const abstractKeywords = [
      '왜', 'why', '어떻게', 'how',
      '의미', 'meaning', '목적', 'purpose',
      '철학', 'philosophy', '윤리', 'ethics',
    ];
    
    // 복잡한 과학
    const complexKeywords = [
      '우주', 'universe', '블랙홀', 'black hole',
      '진화', 'evolution', '공룡', 'dinosaur',
      '뇌', 'brain', '의식', 'consciousness',
    ];
    
    for (final keyword in [...abstractKeywords, ...complexKeywords]) {
      if (question.contains(keyword)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 답변 가능 여부에 따른 응답 생성
  static String? getDirectResponse(String question, AnswerabilityLevel level) {
    switch (level) {
      case AnswerabilityLevel.unanswerable:
        return _getUnanswerableResponse(question);
      case AnswerabilityLevel.uncertain:
        return null; // AI가 조심스럽게 답변하도록 함
      case AnswerabilityLevel.answerable:
        return null; // AI가 정상적으로 답변
    }
  }
  
  /// 답변 불가능한 질문에 대한 응답
  static String _getUnanswerableResponse(String question) {
    final lowerQuestion = question.toLowerCase();
    
    // 전문 분야
    if (lowerQuestion.contains('양자') || 
        lowerQuestion.contains('상대성') ||
        lowerQuestion.contains('미적분')) {
      return '그건 너무 어려운 내용이라 나도 잘 몰라. 과학 선생님께 물어보면 좋을 것 같아!';
    }
    
    // 의학
    if (lowerQuestion.contains('약') || 
        lowerQuestion.contains('치료') ||
        lowerQuestion.contains('진단')) {
      return '건강에 관한 건 의사 선생님께 물어봐야 해. 나는 의사가 아니라서 잘 몰라.';
    }
    
    // 법률
    if (lowerQuestion.contains('법') || 
        lowerQuestion.contains('소송')) {
      return '법에 관한 건 어른들께 물어보는 게 좋겠어. 나도 잘 모르는 내용이야.';
    }
    
    // 미래 예측
    if (lowerQuestion.contains('년 후') || 
        lowerQuestion.contains('미래') ||
        lowerQuestion.contains('될까')) {
      return '미래는 아무도 확실히 알 수 없어. 나도 잘 모르겠어.';
    }
    
    // 개인정보
    if (lowerQuestion.contains('전화번호') || 
        lowerQuestion.contains('주소') ||
        lowerQuestion.contains('비밀번호')) {
      return '그런 개인정보는 알려줄 수 없어. 안전을 위해서야.';
    }
    
    // 실시간 정보
    if (lowerQuestion.contains('지금') || 
        lowerQuestion.contains('오늘') ||
        lowerQuestion.contains('최신')) {
      return '실시간 정보는 나도 모르겠어. 인터넷이나 뉴스를 확인해봐.';
    }
    
    // 기본 응답
    return '그건 나도 잘 모르겠어. 미안해!';
  }
}
