import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokifairy/shared/model/chat_message.dart';

/// 채팅 메시지 리스트 프로바이더
class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [];
  }

  /// 사용자 메시지 추가
  void addUserMessage(String text) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, message];
    
    // 요정 응답 시뮬레이션 (나중에 AI 모델로 대체)
    _addFairyResponse(text);
  }

  /// 요정 응답 추가 (임시 로직)
  void _addFairyResponse(String userMessage) {
    Future.delayed(const Duration(milliseconds: 800), () {
      final responses = _generateResponse(userMessage);
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: responses,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, message];
    });
  }

  /// 임시 응답 생성 로직 (나중에 AI 모델로 대체)
  String _generateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('안녕') || lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return '안녕! 만나서 반가워요! 😊';
    } else if (lowerMessage.contains('이름') || lowerMessage.contains('name')) {
      return '저는 당신의 포켓 요정이에요! ✨';
    } else if (lowerMessage.contains('좋아') || lowerMessage.contains('love') || lowerMessage.contains('like')) {
      return '저도 당신이 좋아요! 💕';
    } else if (lowerMessage.contains('배고') || lowerMessage.contains('hungry') || lowerMessage.contains('먹')) {
      return '간식이 먹고 싶어요! 🍪';
    } else if (lowerMessage.contains('놀') || lowerMessage.contains('play')) {
      return '같이 놀아요! 정말 재미있을 것 같아요! 🎮';
    } else if (lowerMessage.contains('피곤') || lowerMessage.contains('tired') || lowerMessage.contains('자')) {
      return '조금 쉬어야 할 것 같아요... 😴';
    } else {
      final responses = [
        '그렇군요! 재미있네요! ✨',
        '흥미로워요! 더 이야기해 주세요! 🌟',
        '와, 정말요? 신기해요! 💫',
        '그거 좋은데요! 😊',
        '음... 생각해볼게요! 🤔',
      ];
      responses.shuffle();
      return responses.first;
    }
  }

  /// 채팅 기록 초기화
  void clearMessages() {
    state = [];
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(() {
  return ChatNotifier();
});
