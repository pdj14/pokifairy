import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/model/ai_message.dart';
import '../../../shared/providers/ai_providers.dart';
import '../../../shared/services/startup_service.dart';

/// 간단한 UUID 생성 함수
String _generateUuid() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = (timestamp * 1000 + (timestamp % 1000)).toString();
  return 'msg_$random';
}

/// ChatController - AI 채팅 메시지 관리
/// 
/// Notifier를 사용하여 채팅 메시지 목록을 관리합니다.
/// - 메시지 전송 및 AI 응답 스트리밍
/// - 채팅 히스토리 영속성 (PrefsService)
/// - 에러 처리 및 재시도 로직
class ChatController extends Notifier<List<AIMessage>> {
  @override
  List<AIMessage> build() {
    _loadHistory();
    return [];
  }
  
  static const int maxMessages = 100;
  
  /// 메시지 전송 및 AI 응답 받기 (스트리밍 지원)
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    // 1. 사용자 메시지 추가
    final userMessage = AIMessage(
      id: _generateUuid(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
    state = [...state, userMessage];
    await _saveHistory();
    
    // 2. AI 응답 메시지 초기화 (빈 내용으로 시작)
    final aiMessageId = _generateUuid();
    final aiMessage = AIMessage(
      id: aiMessageId,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    state = [...state, aiMessage];
    
    try {
      // 3. Lazy initialization: AI 서비스가 초기화되지 않았다면 먼저 초기화
      final service = ref.read(aiServiceProvider);
      if (!service.isInitialized) {
        // 진행률 시작
        ref.read(aiLoadingProgressProvider.notifier).setProgress(
            const AiLoadingProgress.loading(0.1, '모델 검색 중...'));
        
        // 로딩 메시지 표시
        final loadingMessage = aiMessage.copyWith(
          content: '🤖 AI 모델을 불러오는 중이에요...\n잠시만 기다려주세요!',
          status: MessageStatus.sending,
        );
        state = [
          ...state.where((m) => m.id != aiMessageId),
          loadingMessage,
        ];
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        ref.read(aiLoadingProgressProvider.notifier).setProgress(
            const AiLoadingProgress.loading(0.3, '모델 로드 중...'));
        
        // Lazy initialization 수행
        final initialized = await ref.read(lazyAiInitializationProvider.future);
        
        if (!initialized) {
          ref.read(aiLoadingProgressProvider.notifier).setProgress(
              const AiLoadingProgress.idle());
          throw Exception('AI 서비스 초기화에 실패했습니다');
        }
        
        ref.read(aiLoadingProgressProvider.notifier).setProgress(
            const AiLoadingProgress.loading(0.9, '초기화 완료 중...'));
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        ref.read(aiLoadingProgressProvider.notifier).setProgress(
            const AiLoadingProgress.complete());
        
        // 초기화 완료 후 메시지 초기화
        final readyMessage = aiMessage.copyWith(
          content: '',
          status: MessageStatus.sending,
        );
        state = [
          ...state.where((m) => m.id != aiMessageId),
          readyMessage,
        ];
      }
      
      // 4. AI 서비스에서 스트리밍 응답 받기
      final responseStream = service.generateResponseStream(content);
      
      String accumulatedContent = '';
      
      await for (final chunk in responseStream) {
        accumulatedContent += chunk;
        
        // 스트리밍 중 메시지 업데이트
        final updatedMessage = aiMessage.copyWith(
          content: accumulatedContent,
          status: MessageStatus.sending,
        );
        
        state = [
          ...state.where((m) => m.id != aiMessageId),
          updatedMessage,
        ];
      }
      
      // 5. 완료 상태로 변경
      final finalMessage = AIMessage(
        id: aiMessageId,
        content: accumulatedContent,
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );
      
      state = [
        ...state.where((m) => m.id != aiMessageId),
        finalMessage,
      ];
      
      // 6. 히스토리 저장 및 정리
      _trimHistory();
      await _saveHistory();
      
    } catch (e, stackTrace) {
      print('AI 응답 생성 중 오류 발생: $e');
      print('Stack trace: $stackTrace');
      
      // 에러 메시지로 업데이트
      final errorMessage = AIMessage(
        id: aiMessageId,
        content: '죄송해요, 응답을 생성하는 중에 문제가 발생했어요. 😢\n다시 시도해주시겠어요?',
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
        metadata: {'error': e.toString()},
      );
      
      state = [
        ...state.where((m) => m.id != aiMessageId),
        errorMessage,
      ];
      
      await _saveHistory();
    }
  }
  
  /// 메시지 재시도
  /// 
  /// 에러 상태의 메시지를 재전송합니다.
  Future<void> retryMessage(String messageId) async {
    final message = state.firstWhere(
      (m) => m.id == messageId,
      orElse: () => throw Exception('메시지를 찾을 수 없습니다'),
    );
    
    if (message.status != MessageStatus.error) {
      throw Exception('에러 상태의 메시지만 재시도할 수 있습니다');
    }
    
    // 에러 메시지 제거
    state = state.where((m) => m.id != messageId).toList();
    
    // 이전 사용자 메시지 찾기
    final userMessages = state.where((m) => m.isUser).toList();
    if (userMessages.isEmpty) return;
    
    final lastUserMessage = userMessages.last;
    
    // 마지막 사용자 메시지로 재시도
    await sendMessage(lastUserMessage.content);
  }
  
  /// 채팅 히스토리 로드
  Future<void> _loadHistory() async {
    try {
      final prefsService = ref.read(prefsServiceProvider);
      final messages = await prefsService.loadChatHistory();
      
      if (messages.isNotEmpty) {
        state = messages;
        print('채팅 히스토리 로드 완료: ${messages.length}개 메시지');
      }
    } catch (e) {
      print('채팅 히스토리 로드 실패: $e');
      // 로드 실패 시 빈 상태 유지
      state = [];
    }
  }
  
  /// 채팅 히스토리 저장
  Future<void> _saveHistory() async {
    try {
      final prefsService = ref.read(prefsServiceProvider);
      await prefsService.saveChatHistory(state, maxMessages: maxMessages);
      print('채팅 히스토리 저장 완료: ${state.length}개 메시지');
    } catch (e) {
      print('채팅 히스토리 저장 실패: $e');
    }
  }
  
  /// 히스토리 정리 (최대 개수 제한)
  void _trimHistory() {
    if (state.length > maxMessages) {
      state = state.sublist(state.length - maxMessages);
      print('채팅 히스토리 정리: 최근 $maxMessages개 메시지만 유지');
    }
  }
  
  /// 채팅 히스토리 전체 삭제
  Future<void> clearHistory() async {
    state = [];
    
    try {
      final prefsService = ref.read(prefsServiceProvider);
      await prefsService.clearChatHistory();
      print('채팅 히스토리 삭제 완료');
    } catch (e) {
      print('채팅 히스토리 삭제 실패: $e');
    }
  }

  /// 현재 상태를 즉시 저장 (백그라운드 전환 시 호출)
  Future<void> saveStateNow() async {
    await _saveHistory();
  }
  
  /// 메모리 부족 시 호출 - AI 모델 언로드
  /// 
  /// 메모리 압박 상황에서 AI 모델을 언로드하여 메모리를 확보합니다.
  /// 채팅 히스토리는 유지되며, 다음 메시지 전송 시 모델이 다시 로드됩니다.
  void handleLowMemory() {
    try {
      final service = ref.read(aiServiceProvider);
      if (service.isInitialized) {
        service.unloadModel();
        print('메모리 부족: AI 모델 언로드 완료');
        
        // 사용자에게 알림 메시지 추가 (선택적)
        final warningMessage = AIMessage(
          id: _generateUuid(),
          content: '⚠️ 메모리 부족으로 AI 모델이 일시적으로 언로드되었습니다.\n다음 메시지 전송 시 다시 로드됩니다.',
          isUser: false,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
          metadata: {'type': 'system_warning'},
        );
        state = [...state, warningMessage];
      }
    } catch (e) {
      print('메모리 부족 처리 중 오류: $e');
    }
  }
}

/// ChatController 프로바이더
/// 
/// 채팅 메시지 목록과 관련 액션을 제공합니다.
final chatControllerProvider = NotifierProvider<ChatController, List<AIMessage>>(
  ChatController.new,
);
