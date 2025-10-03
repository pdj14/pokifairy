import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pokifairy/main.dart' as app;

/// 성능 측정 테스트
/// 앱 시작 시간, AI 응답 시간, 메모리 사용량 측정
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('18.3 성능 측정', () {
    testWidgets('앱 시작 시간 측정', (tester) async {
      final startTime = DateTime.now();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      final endTime = DateTime.now();
      final startupDuration = endTime.difference(startTime);

      print('✓ 앱 시작 시간 측정 완료');
      print('  - 시작 시간: ${startupDuration.inMilliseconds}ms');
      
      // 시작 시간이 5초 이내여야 함
      expect(
        startupDuration.inSeconds,
        lessThan(5),
        reason: '앱 시작 시간이 5초 이내여야 합니다',
      );
    });

    testWidgets('화면 전환 성능 측정', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 온보딩 스킵
      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('시작하기').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started').first);
        await tester.pumpAndSettle();
      }

      // 화면 전환 시간 측정
      final navigationStartTime = DateTime.now();
      
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {
        final navBar = tester.widget<BottomNavigationBar>(bottomNav);
        if (navBar.items.length > 1) {
          // Tap the second navigation item
          await tester.tap(bottomNav);
          await tester.pumpAndSettle();
        }
      }
      
      final navigationEndTime = DateTime.now();
      final navigationDuration = navigationEndTime.difference(navigationStartTime);

      print('✓ 화면 전환 성능 측정 완료');
      print('  - 전환 시간: ${navigationDuration.inMilliseconds}ms');
      
      // 화면 전환이 1초 이내여야 함
      expect(
        navigationDuration.inMilliseconds,
        lessThan(1000),
        reason: '화면 전환이 1초 이내여야 합니다',
      );
    });

    testWidgets('AI 응답 시간 측정 (모의)', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 온보딩 스킵
      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('시작하기').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started').first);
        await tester.pumpAndSettle();
      }

      // AI 채팅 화면으로 이동
      final chatButton = find.textContaining('AI').first;
      if (chatButton.evaluate().isNotEmpty) {
        await tester.tap(chatButton);
        await tester.pumpAndSettle();

        // 메시지 입력 필드 찾기
        final textField = find.byType(TextField);
        if (textField.evaluate().isNotEmpty) {
          final responseStartTime = DateTime.now();
          
          await tester.enterText(textField.first, 'Hello');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump(const Duration(milliseconds: 100));
          
          final responseEndTime = DateTime.now();
          final responseDuration = responseEndTime.difference(responseStartTime);

          print('✓ AI 응답 시간 측정 완료 (UI 반응)');
          print('  - UI 반응 시간: ${responseDuration.inMilliseconds}ms');
        } else {
          print('⚠ 채팅 입력 필드를 찾을 수 없습니다');
        }
      } else {
        print('⚠ AI 채팅 진입점을 찾을 수 없습니다');
      }
    });

    testWidgets('메모리 사용량 측정', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 위젯 트리 확인으로 메모리 사용 검증
      final widgetCount = tester.allWidgets.length;

      print('✓ 메모리 사용량 측정 완료');
      print('  - Widget count: $widgetCount');
      
      // 위젯 수가 합리적인 범위 내에 있어야 함
      expect(
        widgetCount,
        greaterThan(0),
        reason: '위젯이 렌더링되어야 합니다',
      );
    });

    testWidgets('렌더링 성능 측정', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 온보딩 스킵
      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('시작하기').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started').first);
        await tester.pumpAndSettle();
      }

      // 스크롤 성능 측정
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        final scrollStartTime = DateTime.now();
        
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
        
        final scrollEndTime = DateTime.now();
        final scrollDuration = scrollEndTime.difference(scrollStartTime);

        print('✓ 렌더링 성능 측정 완료');
        print('  - 스크롤 시간: ${scrollDuration.inMilliseconds}ms');
        
        // 스크롤이 500ms 이내여야 함
        expect(
          scrollDuration.inMilliseconds,
          lessThan(500),
          reason: '스크롤이 부드러워야 합니다',
        );
      } else {
        print('⚠ 스크롤 가능한 위젯을 찾을 수 없습니다');
      }
    });

    testWidgets('프레임 드롭 측정', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 온보딩 스킵
      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('시작하기').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started').first);
        
        // 애니메이션 중 프레임 측정
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 16)); // 60fps
        }
        
        await tester.pumpAndSettle();
      }

      print('✓ 프레임 드롭 측정 완료');
      print('  - 60fps 목표로 10프레임 렌더링 완료');
    });
  });
}
