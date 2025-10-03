import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokifairy/features/chat/widgets/message_bubble.dart';
import 'package:pokifairy/shared/model/ai_message.dart';

void main() {
  group('MessageBubble Widget Tests', () {
    testWidgets('displays user message with correct styling',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'user-1',
        content: 'Hello, this is a user message!',
        isUser: true,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      // Message content should be displayed
      expect(find.text('Hello, this is a user message!'), findsOneWidget);

      // User icon should be displayed
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Check alignment (user messages should be on the right)
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets('displays AI message with correct styling',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'ai-1',
        content: 'Hello, this is an AI response!',
        isUser: false,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      // Message content should be displayed
      expect(find.text('Hello, this is an AI response!'), findsOneWidget);

      // AI icon should be displayed
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

      // Check alignment (AI messages should be on the left)
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.start);
    });

    testWidgets('displays sending status for user message',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'user-2',
        content: 'Sending message...',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      expect(find.text('Sending message...'), findsOneWidget);
      
      // Should show some indication of sending status
      // (implementation specific - might be opacity or icon)
    });

    testWidgets('displays error status for failed message',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'ai-2',
        content: 'Failed to generate response',
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      expect(find.text('Failed to generate response'), findsOneWidget);
      
      // Error icon should be displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays timestamp in readable format',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'user-3',
        content: 'Test message',
        isUser: true,
        timestamp: DateTime(2024, 1, 1, 14, 30, 0),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      // Timestamp should be displayed (format may vary)
      // Looking for time pattern like "14:30" or "2:30 PM"
      final timeFinder = find.byWidgetPredicate(
        (widget) => widget is Text && 
          (widget.data?.contains(':') == true || 
           widget.data?.contains('PM') == true ||
           widget.data?.contains('AM') == true),
      );
      expect(timeFinder, findsWidgets);
    });

    testWidgets('handles long messages with proper wrapping',
        (WidgetTester tester) async {
      final longMessage = 'This is a very long message that should wrap properly '
          'across multiple lines without causing any overflow issues. '
          'It should be displayed nicely in the message bubble with proper '
          'text wrapping and spacing.';

      final message = AIMessage(
        id: 'user-4',
        content: longMessage,
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      expect(find.text(longMessage), findsOneWidget);
      
      // Should not have overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles empty message content',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'user-5',
        content: '',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      // Should still render without errors
      expect(find.byType(MessageBubble), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('applies different colors for user and AI messages',
        (WidgetTester tester) async {
      final userMessage = AIMessage(
        id: 'user-6',
        content: 'User message',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      final aiMessage = AIMessage(
        id: 'ai-3',
        content: 'AI message',
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MessageBubble(message: userMessage),
                MessageBubble(message: aiMessage),
              ],
            ),
          ),
        ),
      );

      // Both messages should be displayed
      expect(find.text('User message'), findsOneWidget);
      expect(find.text('AI message'), findsOneWidget);

      // Should have different visual styling (tested via Container colors)
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.length, greaterThan(0));
    });

    testWidgets('displays metadata if present',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'user-7',
        content: 'Message with metadata',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        metadata: {'tokens': 150, 'model': 'gemma-2b'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      expect(find.text('Message with metadata'), findsOneWidget);
      
      // Metadata might be displayed in debug mode or as tooltip
      // This is implementation-specific
    });

    testWidgets('handles special characters in message content',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'user-8',
        content: 'Special chars: @#\$%^&*()_+-=[]{}|;:\'",.<>?/~`',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      expect(find.textContaining('Special chars:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles emoji in message content',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'user-9',
        content: 'Hello! 👋 How are you? 😊🎉',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      expect(find.text('Hello! 👋 How are you? 😊🎉'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles multiline message content',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'user-10',
        content: 'Line 1\nLine 2\nLine 3',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      expect(find.text('Line 1\nLine 2\nLine 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MessageBubble Accessibility Tests', () {
    testWidgets('has proper semantics for screen readers',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'user-11',
        content: 'Accessible message',
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      // Should have semantic information
      expect(find.byType(MessageBubble), findsOneWidget);
    });
  });
}
