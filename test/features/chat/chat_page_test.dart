import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokifairy/features/chat/chat_page.dart';
import 'package:pokifairy/features/chat/widgets/message_bubble.dart';
import 'package:pokifairy/features/chat/widgets/chat_input.dart';
import 'package:pokifairy/features/chat/widgets/typing_indicator.dart';
import 'package:pokifairy/shared/model/ai_message.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('ChatPage Widget Tests', () {
    Widget createChatPage() {
      return const ProviderScope(
        child: MaterialApp(
          home: ChatPage(),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('ko'),
            Locale('en'),
          ],
        ),
      );
    }

    testWidgets('ChatPage displays empty state when no messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(createChatPage());
      await tester.pumpAndSettle();

      // 빈 상태 아이콘 확인
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('ChatPage displays chat input', (WidgetTester tester) async {
      await tester.pumpWidget(createChatPage());
      await tester.pumpAndSettle();

      // 입력 위젯 확인
      expect(find.byType(ChatInput), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('ChatPage hides clear history button when no messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(createChatPage());
      await tester.pumpAndSettle();

      // 삭제 버튼이 없어야 함
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('ChatPage displays send button', (WidgetTester tester) async {
      await tester.pumpWidget(createChatPage());
      await tester.pumpAndSettle();

      // 전송 버튼 확인
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('ChatPage has AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createChatPage());
      await tester.pumpAndSettle();

      // AppBar 확인
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('MessageBubble Widget Tests', () {
    testWidgets('MessageBubble displays user message correctly',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'test1',
        content: 'Hello from user',
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

      expect(find.text('Hello from user'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('MessageBubble displays AI message correctly',
        (WidgetTester tester) async {
      final message = AIMessage(
        id: 'test2',
        content: 'Hello from AI',
        isUser: false,
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

      expect(find.text('Hello from AI'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });

  group('ChatInput Widget Tests', () {
    testWidgets('ChatInput displays text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko'),
            Locale('en'),
          ],
          home: Scaffold(
            body: ChatInput(onSend: (_) {}),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('ChatInput can be disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko'),
            Locale('en'),
          ],
          home: Scaffold(
            body: ChatInput(
              onSend: (_) {},
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });
  });

  group('TypingIndicator Widget Tests', () {
    testWidgets('TypingIndicator displays animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      expect(find.byType(TypingIndicator), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}
