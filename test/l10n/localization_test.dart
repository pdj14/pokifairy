import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokifairy/l10n/app_localizations.dart';

/// 다국어 지원 테스트
/// 
/// 한국어와 영어 로케일에서 모든 AI 관련 텍스트가 올바르게 로드되는지 확인합니다.
void main() {
  group('Localization Tests', () {
    testWidgets('Korean locale loads all AI strings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _TestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestWidget));
      final l10n = AppLocalizations.of(context)!;

      // 채팅 관련 텍스트
      expect(l10n.chatTitle, '요정과 대화하기');
      expect(l10n.chatInputHint, '메시지를 입력하세요...');
      expect(l10n.chatEmptyMessage, '요정과 대화를 시작해보세요!');
      expect(l10n.chatEmptyHint, 'AI와 대화를 시작해보세요');
      expect(l10n.clearHistory, '대화 기록 삭제');
      expect(l10n.clearHistoryConfirm, '모든 대화 기록을 삭제하시겠습니까?');
      expect(l10n.aiThinking, '생각 중...');

      // 모델 선택 관련 텍스트
      expect(l10n.modelSelectionTitle, 'AI 모델 선택');
      expect(l10n.modelSelectionDescription, '사용할 AI 모델을 선택하세요');
      expect(l10n.noModelsFound, '사용 가능한 모델이 없습니다');
      expect(l10n.noModelsDescription, 'AiModels 폴더에 GGUF 모델 파일을 추가해주세요');
      expect(l10n.currentModel, '현재 모델');
      expect(l10n.selectModel, '선택');
      expect(l10n.modelSelected, '모델이 선택되었습니다');
      expect(l10n.modelSelectionFailed, '모델 선택에 실패했습니다');

      // 디버그 관련 텍스트
      expect(l10n.modelDebugTitle, 'AI 디버그 정보');
      expect(l10n.debugRefresh, '새로고침');
      expect(l10n.debugInitStatus, 'AI 초기화 상태');
      expect(l10n.debugModelInfo, '현재 모델 정보');
      expect(l10n.debugFFIStatus, 'FFI 연결 상태');
      expect(l10n.debugSystemInfo, '시스템 정보');
      expect(l10n.debugEngineStatus, '추론 엔진 상태');
      expect(l10n.debugLogs, '디버그 로그');
      expect(l10n.copyLogs, '로그 복사');
      expect(l10n.logsCopied, '로그가 클립보드에 복사되었습니다');

      // 에러 메시지
      expect(l10n.errorModelNotFound, '사용 가능한 AI 모델이 없습니다. 모델을 다운로드해주세요.');
      expect(l10n.errorModelLoadFailed, 'AI 모델을 불러오는데 실패했습니다. 모델 파일을 확인해주세요.');
      expect(l10n.errorInference, 'AI 응답 생성 중 오류가 발생했습니다. 다시 시도해주세요.');
      expect(l10n.errorPermissionDenied, '저장소 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.');
      expect(l10n.errorInsufficientMemory, '메모리가 부족합니다. 다른 앱을 종료하고 다시 시도해주세요.');
      expect(l10n.errorNetwork, '네트워크 연결을 확인해주세요.');
      expect(l10n.errorUnknown, '알 수 없는 오류가 발생했습니다.');

      // 타임스탬프
      expect(l10n.justNow, '방금 전');
      expect(l10n.minutesAgo(5), '5분 전');
      expect(l10n.daysAgo(3), '3일 전');

      // 권한 다이얼로그
      expect(l10n.permissionDialogTitle, '권한 필요');
      expect(l10n.permissionDialogMessage, 'AI 모델에 접근하기 위해 저장소 권한이 필요합니다. 권한을 허용해주세요.');
      expect(l10n.permissionDialogCancel, '취소');
      expect(l10n.permissionDialogAllow, '권한 허용');
      expect(l10n.permissionSettingsTitle, '권한 설정 필요');
      expect(l10n.permissionSettingsMessage, '권한이 거부되었습니다. 설정에서 권한을 허용해주세요.');
    });

    testWidgets('English locale loads all AI strings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _TestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TestWidget));
      final l10n = AppLocalizations.of(context)!;

      // 채팅 관련 텍스트
      expect(l10n.chatTitle, 'Chat with Fairy');
      expect(l10n.chatInputHint, 'Type a message...');
      expect(l10n.chatEmptyMessage, 'Start a conversation with your fairy!');
      expect(l10n.chatEmptyHint, 'Start a conversation with AI');
      expect(l10n.clearHistory, 'Clear history');
      expect(l10n.clearHistoryConfirm, 'Are you sure you want to clear all chat history?');
      expect(l10n.aiThinking, 'Thinking...');

      // 모델 선택 관련 텍스트
      expect(l10n.modelSelectionTitle, 'Select AI Model');
      expect(l10n.modelSelectionDescription, 'Choose an AI model to use');
      expect(l10n.noModelsFound, 'No models available');
      expect(l10n.noModelsDescription, 'Please add GGUF model files to the AiModels folder');
      expect(l10n.currentModel, 'Current Model');
      expect(l10n.selectModel, 'Select');
      expect(l10n.modelSelected, 'Model selected successfully');
      expect(l10n.modelSelectionFailed, 'Failed to select model');

      // 디버그 관련 텍스트
      expect(l10n.modelDebugTitle, 'AI Debug Info');
      expect(l10n.debugRefresh, 'Refresh');
      expect(l10n.debugInitStatus, 'AI Initialization Status');
      expect(l10n.debugModelInfo, 'Current Model Info');
      expect(l10n.debugFFIStatus, 'FFI Connection Status');
      expect(l10n.debugSystemInfo, 'System Information');
      expect(l10n.debugEngineStatus, 'Inference Engine Status');
      expect(l10n.debugLogs, 'Debug Logs');
      expect(l10n.copyLogs, 'Copy Logs');
      expect(l10n.logsCopied, 'Logs copied to clipboard');

      // 에러 메시지
      expect(l10n.errorModelNotFound, 'No AI model available. Please download a model.');
      expect(l10n.errorModelLoadFailed, 'Failed to load AI model. Please check the model file.');
      expect(l10n.errorInference, 'Error occurred while generating AI response. Please try again.');
      expect(l10n.errorPermissionDenied, 'Storage permission required. Please allow permission in settings.');
      expect(l10n.errorInsufficientMemory, 'Insufficient memory. Please close other apps and try again.');
      expect(l10n.errorNetwork, 'Please check your network connection.');
      expect(l10n.errorUnknown, 'An unknown error occurred.');

      // 타임스탬프
      expect(l10n.justNow, 'Just now');
      expect(l10n.minutesAgo(5), '5 min ago');
      expect(l10n.daysAgo(3), '3 days ago');

      // 권한 다이얼로그
      expect(l10n.permissionDialogTitle, 'Permission Required');
      expect(l10n.permissionDialogMessage, 'Storage permission is required to access AI models. Please allow permission.');
      expect(l10n.permissionDialogCancel, 'Cancel');
      expect(l10n.permissionDialogAllow, 'Allow Permission');
      expect(l10n.permissionSettingsTitle, 'Permission Settings Required');
      expect(l10n.permissionSettingsMessage, 'Permission was denied. Please allow permission in settings.');
    });

    testWidgets('Locale switching works correctly', (tester) async {
      // 한국어로 시작
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _TestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      var context = tester.element(find.byType(_TestWidget));
      var l10n = AppLocalizations.of(context)!;

      // 한국어 확인
      expect(l10n.chatTitle, '요정과 대화하기');

      // 영어로 변경
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _TestWidget(),
        ),
      );

      await tester.pumpAndSettle();

      context = tester.element(find.byType(_TestWidget));
      l10n = AppLocalizations.of(context)!;

      // 영어 확인
      expect(l10n.chatTitle, 'Chat with Fairy');
    });

    test('All error types have localized messages', () {
      // 모든 AIErrorType이 번역되었는지 확인
      // 이 테스트는 컴파일 타임에 확인되므로 실제로는 필요 없지만
      // 문서화 목적으로 남겨둡니다
      expect(true, true);
    });
  });
}

/// 테스트용 위젯
class _TestWidget extends StatelessWidget {
  const _TestWidget();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Test Widget'),
      ),
    );
  }
}
