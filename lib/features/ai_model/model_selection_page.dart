import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/providers/ai_providers.dart';
import 'package:pokifairy/shared/services/ai/model_manager.dart';
import 'package:pokifairy/features/ai_model/widgets/model_card.dart';
import 'package:pokifairy/shared/widgets/permission_request_dialog.dart';

/// AI 모델 선택 화면
/// 
/// 사용자가 디바이스에 저장된 GGUF 모델 중 하나를 선택할 수 있습니다.
/// - 사용 가능한 모델 목록 표시
/// - 현재 선택된 모델 하이라이트
/// - 모델 선택 및 AI 서비스 재초기화
class ModelSelectionPage extends ConsumerStatefulWidget {
  const ModelSelectionPage({super.key});

  @override
  ConsumerState<ModelSelectionPage> createState() => _ModelSelectionPageState();
}

class _ModelSelectionPageState extends ConsumerState<ModelSelectionPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // 스캔된 모델 목록
    final scannedModelsAsync = ref.watch(scannedModelsProvider);
    
    // 현재 선택된 모델
    final currentModelAsync = ref.watch(currentModelInfoProvider);
    
    // 디버그: 현재 모델 상태 확인
    currentModelAsync.whenData((model) {
      if (model != null) {
        debugPrint('현재 선택된 모델: ${model.name} (${model.path})');
      } else {
        debugPrint('현재 선택된 모델 없음');
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(l10n.modelSelectionTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshModels,
            onPressed: () {
              // 모델 목록 새로고침
              ref.invalidate(scannedModelsProvider);
              ref.invalidate(currentModelInfoProvider);
            },
          ),
        ],
      ),
      body: scannedModelsAsync.when(
        data: (models) {
          if (models.isEmpty) {
            return _buildEmptyState(context, l10n, theme);
          }
          
          return currentModelAsync.when(
            data: (currentModel) => _buildModelList(
              context,
              l10n,
              theme,
              models,
              currentModel,
            ),
            loading: () => _buildModelList(
              context,
              l10n,
              theme,
              models,
              null,
            ),
            error: (_, __) => _buildModelList(
              context,
              l10n,
              theme,
              models,
              null,
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(context, l10n, theme, error),
      ),
    );
  }
  
  /// 모델 목록 빌드
  Widget _buildModelList(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    List<ModelInfo> models,
    ModelInfo? currentModel,
  ) {
    return Column(
      children: [
        // 설명 헤더
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.modelSelectionDescription,
                style: theme.textTheme.bodyLarge,
              ),
              if (currentModel != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.currentModel}: ${currentModel.name}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // 모델 목록
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              final isSelected = currentModel?.path == model.path;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ModelCard(
                  model: model,
                  isSelected: isSelected,
                  onSelect: () => _selectModel(context, model),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// 빈 상태 빌드
  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noModelsFound,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noModelsDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _checkPermission(context),
              icon: const Icon(Icons.folder),
              label: Text(l10n.requestPermission),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 에러 상태 빌드
  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Object error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.permissionRequired,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _checkPermission(context),
              icon: const Icon(Icons.settings),
              label: Text(l10n.requestPermission),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 권한 확인 및 요청
  Future<void> _checkPermission(BuildContext context) async {
    final hasPermission = await ModelManager.requestStoragePermission();
    
    if (!hasPermission && context.mounted) {
      // 권한이 없으면 다이얼로그 표시
      await showDialog(
        context: context,
        builder: (context) => const PermissionRequestDialog(),
      );
    } else if (context.mounted) {
      // 권한이 있으면 모델 목록 새로고침
      ref.invalidate(scannedModelsProvider);
    }
  }
  
  /// 모델 선택
  Future<void> _selectModel(BuildContext context, ModelInfo model) async {
    final l10n = AppLocalizations.of(context)!;
    
    // 로딩 다이얼로그 표시
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('${model.name}\n모델을 로드하는 중...'),
            ],
          ),
        ),
      );
    }
    
    try {
      // 1. 모델 경로 저장
      await ModelManager.setCurrentModel(model.path);
      
      // 2. 현재 모델 상태 업데이트
      ref.read(currentModelProvider.notifier).setModel(model);
      
      // 3. AI 서비스 재초기화 (기존 모델 언로드 및 새 모델 로드)
      final aiService = ref.read(aiServiceProvider);
      print('모델 변경: 기존 모델 언로드 중...');
      aiService.dispose(); // 기존 모델 완전히 정리
      
      print('모델 변경: 새 모델 로드 중... (${model.name})');
      final reinitialized = await aiService.reinitialize();
      
      if (!reinitialized) {
        throw Exception('새 모델 로드 실패');
      }
      
      // 4. 프로바이더 무효화
      ref.invalidate(aiInitializationProvider);
      ref.invalidate(lazyAiInitializationProvider);
      ref.invalidate(currentModelInfoProvider);
      
      print('모델 변경 완료: ${model.name}');
      
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // 5. 성공 메시지 표시 및 이전 화면으로 돌아가기
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${l10n.modelSelected}\n${model.name}'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // 모델 선택 후 이전 화면으로 돌아가기
        if (context.canPop()) {
          context.pop();
        }
      }
      
    } catch (e) {
      print('모델 선택 실패: $e');
      
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // 에러 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.modelSelectionFailed}\n$e'),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
