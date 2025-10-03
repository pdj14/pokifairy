import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokifairy/features/ai_model/model_selection_page.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/providers/ai_providers.dart';
import 'package:pokifairy/shared/services/ai/model_manager.dart';

void main() {
  group('ModelSelectionPage', () {
    // 테스트용 모델 데이터
    final testModels = [
      ModelInfo(
        name: 'gemma-2b-Q4_K_M.gguf',
        path: '/storage/emulated/0/AiModels/gemma-2b-Q4_K_M.gguf',
        size: 1500000000,
        formattedSize: '1.4GB',
        architecture: 'Gemma',
        quantization: 'Q4_K_M',
      ),
      ModelInfo(
        name: 'llama-3-8b-Q5_K_M.gguf',
        path: '/storage/emulated/0/AiModels/llama-3-8b-Q5_K_M.gguf',
        size: 5500000000,
        formattedSize: '5.1GB',
        architecture: 'Llama',
        quantization: 'Q5_K_M',
      ),
    ];

    Widget createTestWidget({
      List<ModelInfo>? models,
      ModelInfo? currentModel,
      bool hasError = false,
    }) {
      return ProviderScope(
        overrides: [
          // 스캔된 모델 목록 오버라이드
          scannedModelsProvider.overrideWith((ref) async {
            if (hasError) {
              throw Exception('Permission denied');
            }
            return models ?? testModels;
          }),
          // 현재 모델 오버라이드
          currentModelInfoProvider.overrideWith((ref) async {
            return currentModel;
          }),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ModelSelectionPage(),
        ),
      );
    }

    testWidgets('모델 목록이 표시되어야 함', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // 로딩 표시 대기
      await tester.pump();
      
      // 데이터 로드 대기
      await tester.pumpAndSettle();

      // 모델 이름이 표시되는지 확인
      expect(find.text('gemma-2b-Q4_K_M.gguf'), findsOneWidget);
      expect(find.text('llama-3-8b-Q5_K_M.gguf'), findsOneWidget);
      
      // 모델 크기가 표시되는지 확인
      expect(find.text('1.4GB'), findsOneWidget);
      expect(find.text('5.1GB'), findsOneWidget);
    });

    testWidgets('현재 선택된 모델이 하이라이트되어야 함', (tester) async {
      await tester.pumpWidget(
        createTestWidget(currentModel: testModels[0]),
      );
      
      await tester.pumpAndSettle();

      // 체크 아이콘이 표시되는지 확인
      expect(find.byIcon(Icons.check), findsOneWidget);
      
      // "현재 모델" 텍스트가 표시되는지 확인
      expect(find.textContaining('gemma-2b-Q4_K_M.gguf'), findsWidgets);
    });

    testWidgets('모델이 없을 때 빈 상태가 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        createTestWidget(models: []),
      );
      
      await tester.pumpAndSettle();

      // 빈 상태 아이콘 확인
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
      
      // 빈 상태 메시지 확인 (한국어 또는 영어)
      final noModelsText = find.byWidgetPredicate(
        (widget) => widget is Text && 
          (widget.data?.contains('사용 가능한 모델이 없습니다') == true ||
           widget.data?.contains('No models available') == true),
      );
      expect(noModelsText, findsOneWidget);
    });

    testWidgets('에러 상태가 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        createTestWidget(hasError: true),
      );
      
      await tester.pumpAndSettle();

      // 에러 아이콘 확인
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // 에러 메시지 확인
      expect(find.textContaining('Permission denied'), findsOneWidget);
    });

    testWidgets('새로고침 버튼이 동작해야 함', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.pumpAndSettle();

      // 새로고침 버튼 찾기
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      // 새로고침 버튼 탭
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // 모델 목록이 다시 표시되는지 확인
      expect(find.text('gemma-2b-Q4_K_M.gguf'), findsOneWidget);
    });

    testWidgets('모델 선택 버튼이 표시되어야 함', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.pumpAndSettle();

      // 선택 버튼 찾기 (선택되지 않은 모델에만 표시)
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(2));
    });

    testWidgets('선택된 모델에는 선택 버튼이 표시되지 않아야 함', (tester) async {
      await tester.pumpWidget(
        createTestWidget(currentModel: testModels[0]),
      );
      
      await tester.pumpAndSettle();

      // 첫 번째 모델은 선택되어 있으므로 선택 버튼이 1개만 있어야 함
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      
      // 선택된 모델에는 체크 아이콘이 표시되어야 함
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('모델 카드에 아키텍처와 양자화 정보가 표시되어야 함', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.pumpAndSettle();

      // 아키텍처 정보 확인
      expect(find.text('Gemma'), findsOneWidget);
      expect(find.text('Llama'), findsOneWidget);
      
      // 양자화 정보 확인
      expect(find.text('Q4_K_M'), findsOneWidget);
      expect(find.text('Q5_K_M'), findsOneWidget);
    });

    testWidgets('AppBar에 제목이 표시되어야 함', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.pumpAndSettle();

      // AppBar 제목 확인 (한국어 또는 영어)
      final titleText = find.byWidgetPredicate(
        (widget) => widget is Text && 
          (widget.data == 'AI 모델 선택' || widget.data == 'Select AI Model'),
      );
      expect(titleText, findsOneWidget);
    });
  });
}
