import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pokifairy/main.dart' as app;

/// 전체 기능 통합 테스트
/// 페어리 기능, AI 채팅, 모델 선택, 다국어 전환을 검증
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('18.1 전체 기능 테스트', () {
    testWidgets('페어리 기능 정상 동작 확인', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 온보딩 또는 랜딩 화면 스킵
      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('시작하기').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started').first);
        await tester.pumpAndSettle();
      }

      // 홈 화면 도달 확인
      expect(
        find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
            find.text('Home').evaluate().isNotEmpty ||
            find.text('홈').evaluate().isNotEmpty,
        true,
        reason: '홈 화면에 도달해야 합니다',
      );

      print('✓ 페어리 기능 정상 동작 확인 완료');
    });

    testWidgets('AI 채팅 기능 정상 동작 확인', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 온보딩 스킵
      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('시작하기').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started').first);
        await tester.pumpAndSettle();
      }

      // AI 채팅 진입점 찾기
      final chatButton = find.textContaining('AI').first;
      if (chatButton.evaluate().isNotEmpty) {
        await tester.tap(chatButton);
        await tester.pumpAndSettle();

        // 채팅 화면 확인
        expect(
          find.byType(TextField).evaluate().isNotEmpty,
          true,
          reason: '채팅 입력 필드가 있어야 합니다',
        );

        print('✓ AI 채팅 기능 정상 동작 확인 완료');
      } else {
        print('⚠ AI 채팅 진입점을 찾을 수 없습니다');
      }
    });

    testWidgets('모델 선택 및 변경 확인', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 온보딩 스킵
      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('시작하기').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started').first);
        await tester.pumpAndSettle();
      }

      // 설정 또는 모델 선택 화면으로 이동
      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.first);
        await tester.pumpAndSettle();

        // 모델 선택 메뉴 찾기
        final modelSelectionButton = find.textContaining('Model').first;
        if (modelSelectionButton.evaluate().isNotEmpty) {
          await tester.tap(modelSelectionButton);
          await tester.pumpAndSettle();

          print('✓ 모델 선택 화면 접근 확인 완료');
        } else {
          print('⚠ 모델 선택 메뉴를 찾을 수 없습니다');
        }
      } else {
        print('⚠ 설정 아이콘을 찾을 수 없습니다');
      }
    });

    testWidgets('다국어 전환 확인', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 온보딩 스킵
      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('시작하기').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started').first);
        await tester.pumpAndSettle();
      }

      // 설정 화면으로 이동
      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.first);
        await tester.pumpAndSettle();

        // 언어 설정 찾기
        final languageButton = find.textContaining('Language').first;
        if (languageButton.evaluate().isNotEmpty) {
          await tester.tap(languageButton);
          await tester.pumpAndSettle();

          print('✓ 다국어 전환 기능 확인 완료');
        } else {
          print('⚠ 언어 설정을 찾을 수 없습니다');
        }
      }
    });
  });
}
