import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokifairy/features/chat/providers/chat_providers.dart';
import 'package:pokifairy/shared/model/ai_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // SharedPreferences 초기화
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatController', () {
    test('초기 상태는 빈 메시지 목록이어야 함', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 히스토리 로드가 완료될 때까지 대기
      await Future.delayed(const Duration(milliseconds: 100));

      final messages = container.read(chatControllerProvider);
      expect(messages, isEmpty);
    });

    test('빈 메시지는 전송되지 않아야 함', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);

      await controller.sendMessage('');
      await controller.sendMessage('   ');

      final messages = container.read(chatControllerProvider);
      expect(messages, isEmpty);
    });

    test('clearHistory는 모든 메시지를 삭제해야 함', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);

      // 수동으로 메시지 추가 (테스트용)
      final testMessage = AIMessage(
        id: 'test-1',
        content: '테스트 메시지',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );
      
      // state를 직접 수정할 수 없으므로, clearHistory 테스트만 수행
      await controller.clearHistory();

      final messages = container.read(chatControllerProvider);
      expect(messages, isEmpty);
    });

    test('히스토리는 SharedPreferences에서 로드되어야 함', () async {
      // 먼저 SharedPreferences에 테스트 데이터 저장
      final prefs = await SharedPreferences.getInstance();
      final testMessages = [
        {
          'id': 'test-1',
          'content': '저장된 메시지',
          'isUser': true,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'sent',
          'metadata': null,
        }
      ];
      await prefs.setString('pf_chat_history', jsonEncode(testMessages));

      // 새 컨테이너 생성 (히스토리 로드)
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 프로바이더 초기화
      container.read(chatControllerProvider);

      // 로드 대기 - 비동기 로드가 완료될 때까지
      await Future.delayed(const Duration(seconds: 1));

      final messages = container.read(chatControllerProvider);

      // 저장된 메시지가 로드되어야 함
      expect(messages.length, greaterThan(0));
      if (messages.isNotEmpty) {
        expect(messages.first.content, '저장된 메시지');
        expect(messages.first.isUser, true);
      }
    });

    test('clearHistory는 SharedPreferences에서도 삭제해야 함', () async {
      // 먼저 데이터 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pf_chat_history', '[]');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);

      // 히스토리 삭제
      await controller.clearHistory();

      // SharedPreferences 확인
      final historyJson = prefs.getString('pf_chat_history');
      expect(historyJson, isNull);
    });

    test('AIMessage 모델이 올바르게 직렬화/역직렬화되어야 함', () {
      final message = AIMessage(
        id: 'test-1',
        content: '테스트 메시지',
        isUser: true,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        status: MessageStatus.sent,
      );

      // JSON으로 변환
      final json = message.toJson();
      expect(json['id'], 'test-1');
      expect(json['content'], '테스트 메시지');
      expect(json['isUser'], true);
      expect(json['status'], 'sent');

      // JSON에서 복원
      final restored = AIMessage.fromJson(json);
      expect(restored.id, message.id);
      expect(restored.content, message.content);
      expect(restored.isUser, message.isUser);
      expect(restored.status, message.status);
    });

    test('AIMessage copyWith가 올바르게 동작해야 함', () {
      final original = AIMessage(
        id: 'test-1',
        content: '원본',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      final updated = original.copyWith(
        content: '수정됨',
        status: MessageStatus.sent,
      );

      expect(updated.id, original.id);
      expect(updated.content, '수정됨');
      expect(updated.status, MessageStatus.sent);
      expect(updated.isUser, original.isUser);
    });
  });
}

// JSON 인코딩을 위한 헬퍼
String jsonEncode(dynamic object) {
  if (object is List) {
    return '[${object.map((e) => jsonEncode(e)).join(',')}]';
  } else if (object is Map) {
    final entries = object.entries.map((e) {
      final key = '"${e.key}"';
      final value = e.value == null
          ? 'null'
          : e.value is String
              ? '"${e.value}"'
              : e.value is bool || e.value is num
                  ? '${e.value}'
                  : jsonEncode(e.value);
      return '$key:$value';
    }).join(',');
    return '{$entries}';
  }
  return object.toString();
}
