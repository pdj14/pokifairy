import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokifairy/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Runs widget smoke tests for the PokiFairy application shell.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows onboarding form by default', (tester) async {
    SharedPreferences.setMockInitialValues(const {});

    await tester.pumpWidget(const ProviderScope(child: PokifairyApp()));
    await tester.pumpAndSettle();

    expect(find.text('요정 만들기'), findsOneWidget);
  });
}
