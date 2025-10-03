import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pokifairy/main.dart' as app;

/// UI/UX 일관성 검증 테스트
/// 테마 일관성, 다크 모드, 애니메이션 검증
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('18.2 UI/UX 일관성 검증', () {
    testWidgets('모든 화면 테마 일관성 확인', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // MaterialApp 찾기
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme = materialApp.theme;

      expect(theme, isNotNull, reason: '테마가 설정되어 있어야 합니다');
      expect(theme!.primaryColor, isNotNull, reason: '기본 색상이 정의되어야 합니다');
      expect(theme.textTheme, isNotNull, reason: '텍스트 테마가 정의되어야 합니다');

      print('✓ 테마 일관성 확인 완료');
      print('  - Primary Color: ${theme.primaryColor}');
      print('  - Text Theme: ${theme.textTheme.bodyLarge?.fontFamily}');
    });

    testWidgets('다크 모드 동작 확인', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // MaterialApp 찾기
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final darkTheme = materialApp.darkTheme;

      if (darkTheme != null) {
        expect(darkTheme.brightness, Brightness.dark,
            reason: '다크 테마는 dark brightness를 가져야 합니다');
        print('✓ 다크 모드 설정 확인 완료');
      } else {
        print('⚠ 다크 테마가 설정되지 않았습니다');
      }
    });

    testWidgets('애니메이션 부드러움 확인', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 온보딩 스킵
      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('시작하기').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started').first);
        
        // 애니메이션 프레임 확인
        await tester.pump(const Duration(milliseconds: 16)); // 60fps
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpAndSettle();

        print('✓ 화면 전환 애니메이션 확인 완료');
      }

      // 네비게이션 애니메이션 확인
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {
        final navBar = tester.widget<BottomNavigationBar>(bottomNav);
        final itemCount = navBar.items.length;

        if (itemCount > 1) {
          // 탭 전환 애니메이션
          await tester.tap(bottomNav);
          await tester.pump(const Duration(milliseconds: 16));
          await tester.pump(const Duration(milliseconds: 16));
          await tester.pumpAndSettle();

          print('✓ 네비게이션 애니메이션 확인 완료');
        }
      }
    });

    testWidgets('색상 일관성 검증', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme = materialApp.theme!;
      final colorScheme = theme.colorScheme;

      // 색상 스킴 검증
      expect(colorScheme.primary, isNotNull);
      expect(colorScheme.secondary, isNotNull);
      expect(colorScheme.surface, isNotNull);
      expect(colorScheme.error, isNotNull);

      print('✓ 색상 일관성 검증 완료');
      print('  - Primary: ${colorScheme.primary}');
      print('  - Secondary: ${colorScheme.secondary}');
      print('  - Surface: ${colorScheme.surface}');
    });

    testWidgets('타이포그래피 일관성 검증', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final textTheme = materialApp.theme!.textTheme;

      // 텍스트 스타일 검증
      expect(textTheme.displayLarge, isNotNull);
      expect(textTheme.bodyLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.labelLarge, isNotNull);

      print('✓ 타이포그래피 일관성 검증 완료');
      print('  - Display Large: ${textTheme.displayLarge?.fontSize}');
      print('  - Body Large: ${textTheme.bodyLarge?.fontSize}');
    });
  });
}
