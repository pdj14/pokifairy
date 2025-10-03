import 'package:flutter_test/flutter_test.dart';
import 'package:pokifairy/shared/model/ai_message.dart';

void main() {
  group('AIMessage', () {
    test('should create AIMessage with required fields', () {
      final timestamp = DateTime.now();
      final message = AIMessage(
        id: '1',
        content: 'Hello, AI!',
        isUser: true,
        timestamp: timestamp,
      );

      expect(message.id, '1');
      expect(message.content, 'Hello, AI!');
      expect(message.isUser, true);
      expect(message.timestamp, timestamp);
      expect(message.status, MessageStatus.sent);
      expect(message.metadata, null);
    });

    test('should create AIMessage with all fields', () {
      final timestamp = DateTime.now();
      final metadata = {'key': 'value'};
      final message = AIMessage(
        id: '2',
        content: 'AI response',
        isUser: false,
        timestamp: timestamp,
        status: MessageStatus.sending,
        metadata: metadata,
      );

      expect(message.id, '2');
      expect(message.content, 'AI response');
      expect(message.isUser, false);
      expect(message.timestamp, timestamp);
      expect(message.status, MessageStatus.sending);
      expect(message.metadata, metadata);
    });

    test('should serialize to JSON correctly', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final message = AIMessage(
        id: '3',
        content: 'Test message',
        isUser: true,
        timestamp: timestamp,
        status: MessageStatus.sent,
        metadata: {'test': 'data'},
      );

      final json = message.toJson();

      expect(json['id'], '3');
      expect(json['content'], 'Test message');
      expect(json['isUser'], true);
      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['status'], 'sent');
      expect(json['metadata'], {'test': 'data'});
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': '4',
        'content': 'Deserialized message',
        'isUser': false,
        'timestamp': '2024-01-01T12:00:00.000',
        'status': 'error',
        'metadata': {'error': 'details'},
      };

      final message = AIMessage.fromJson(json);

      expect(message.id, '4');
      expect(message.content, 'Deserialized message');
      expect(message.isUser, false);
      expect(message.timestamp, DateTime(2024, 1, 1, 12, 0, 0));
      expect(message.status, MessageStatus.error);
      expect(message.metadata, {'error': 'details'});
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': '5',
        'content': 'Minimal message',
        'isUser': true,
        'timestamp': '2024-01-01T12:00:00.000',
        'status': 'sent',
      };

      final message = AIMessage.fromJson(json);

      expect(message.id, '5');
      expect(message.content, 'Minimal message');
      expect(message.isUser, true);
      expect(message.status, MessageStatus.sent);
      expect(message.metadata, null);
    });

    test('should handle invalid status in JSON with fallback', () {
      final json = {
        'id': '6',
        'content': 'Invalid status message',
        'isUser': true,
        'timestamp': '2024-01-01T12:00:00.000',
        'status': 'invalid_status',
      };

      final message = AIMessage.fromJson(json);

      expect(message.status, MessageStatus.sent); // Should fallback to sent
    });

    test('should create copy with updated fields', () {
      final original = AIMessage(
        id: '7',
        content: 'Original',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      final updated = original.copyWith(
        content: 'Updated',
        status: MessageStatus.sent,
      );

      expect(updated.id, original.id);
      expect(updated.content, 'Updated');
      expect(updated.isUser, original.isUser);
      expect(updated.timestamp, original.timestamp);
      expect(updated.status, MessageStatus.sent);
    });

    test('should maintain equality for same content', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final message1 = AIMessage(
        id: '8',
        content: 'Same',
        isUser: true,
        timestamp: timestamp,
        status: MessageStatus.sent,
      );

      final message2 = AIMessage(
        id: '8',
        content: 'Same',
        isUser: true,
        timestamp: timestamp,
        status: MessageStatus.sent,
      );

      expect(message1, equals(message2));
      expect(message1.hashCode, equals(message2.hashCode));
    });

    test('should not be equal for different content', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final message1 = AIMessage(
        id: '9',
        content: 'Different',
        isUser: true,
        timestamp: timestamp,
      );

      final message2 = AIMessage(
        id: '10',
        content: 'Different',
        isUser: true,
        timestamp: timestamp,
      );

      expect(message1, isNot(equals(message2)));
    });

    test('should have readable toString', () {
      final message = AIMessage(
        id: '11',
        content: 'This is a very long message that should be truncated',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      final string = message.toString();

      expect(string, contains('AIMessage'));
      expect(string, contains('id: 11'));
      expect(string, contains('isUser: true'));
      expect(string, contains('status: MessageStatus.sent'));
    });
  });

  group('MessageStatus', () {
    test('should have correct enum values', () {
      expect(MessageStatus.values.length, 3);
      expect(MessageStatus.values, contains(MessageStatus.sending));
      expect(MessageStatus.values, contains(MessageStatus.sent));
      expect(MessageStatus.values, contains(MessageStatus.error));
    });

    test('should serialize enum name correctly', () {
      expect(MessageStatus.sending.name, 'sending');
      expect(MessageStatus.sent.name, 'sent');
      expect(MessageStatus.error.name, 'error');
    });
  });
}
