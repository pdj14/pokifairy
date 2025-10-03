import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai/ai_service.dart';
import '../services/ai/model_manager.dart';

/// AI 서비스 싱글톤 인스턴스 프로바이더
/// 
/// AIService의 싱글톤 인스턴스를 제공합니다.
/// 앱 전체에서 동일한 AIService 인스턴스를 사용합니다.
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService.instance;
});

/// AI 서비스 초기화 상태 프로바이더
/// 
/// AI 서비스의 초기화 상태를 관리합니다.
/// - data: 초기화 성공 여부 (true/false)
/// - loading: 초기화 진행 중
/// - error: 초기화 실패 시 에러 정보
/// 
/// 주의: 이 프로바이더는 더 이상 앱 시작 시 자동으로 호출되지 않습니다.
/// 대신 lazyAiInitializationProvider를 사용하여 필요할 때만 초기화합니다.
final aiInitializationProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(aiServiceProvider);
  return await service.initialize();
});

/// AI 모델 로딩 진행률 상태
class AiLoadingProgress {
  final double progress; // 0.0 ~ 1.0
  final String message;
  final bool isComplete;
  
  const AiLoadingProgress({
    required this.progress,
    required this.message,
    this.isComplete = false,
  });
  
  const AiLoadingProgress.idle()
      : progress = 0.0,
        message = '',
        isComplete = false;
  
  const AiLoadingProgress.loading(this.progress, this.message)
      : isComplete = false;
  
  const AiLoadingProgress.complete()
      : progress = 1.0,
        message = '완료',
        isComplete = true;
}

/// AI 로딩 진행률 Notifier
class AiLoadingProgressNotifier extends Notifier<AiLoadingProgress> {
  @override
  AiLoadingProgress build() => const AiLoadingProgress.idle();
  
  void setProgress(AiLoadingProgress progress) {
    state = progress;
  }
}

/// AI 로딩 진행률 프로바이더
/// 
/// AI 모델 로딩 중 진행률을 추적합니다.
final aiLoadingProgressProvider = NotifierProvider<AiLoadingProgressNotifier, AiLoadingProgress>(
  AiLoadingProgressNotifier.new,
);

/// Lazy AI 초기화 프로바이더
/// 
/// 앱 시작 시가 아닌 첫 채팅 시에만 AI를 초기화합니다.
/// 진행률 업데이트는 chat_controller에서 수행합니다.
final lazyAiInitializationProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(aiServiceProvider);
  
  // 이미 초기화되어 있으면 바로 반환
  if (service.isInitialized) {
    return true;
  }
  
  // 실제 초기화 수행 (진행률 업데이트는 chat_controller에서)
  final result = await service.initialize();
  return result;
});

/// AI 응답 스트림 프로바이더
/// 
/// 주어진 프롬프트에 대한 AI 응답을 스트리밍으로 제공합니다.
/// 
/// 사용 예:
/// ```dart
/// final responseStream = ref.watch(aiResponseStreamProvider('안녕하세요'));
/// responseStream.when(
///   data: (text) => Text(text),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
final aiResponseStreamProvider = StreamProvider.family<String, String>(
  (ref, prompt) {
    final service = ref.watch(aiServiceProvider);
    return service.generateResponseStream(prompt);
  },
);

/// 사용 가능한 AI 모델 목록 프로바이더
/// 
/// 디바이스에서 사용 가능한 모든 AI 모델의 정보를 제공합니다.
/// 각 모델의 경로, 크기, 존재 여부 등의 정보를 포함합니다.
final availableModelsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(aiServiceProvider);
  return await service.getAvailableModelsInfo();
});

/// 모델 설치 가이드 프로바이더
/// 
/// AI 모델 설치 방법에 대한 가이드 텍스트를 제공합니다.
final modelInstallationGuideProvider = Provider<String>((ref) {
  final service = ref.watch(aiServiceProvider);
  return service.getModelInstallationGuide();
});

/// AI 모델 정보 프로바이더
/// 
/// 현재 로드된 AI 모델의 상세 정보를 제공합니다.
/// 모델이 로드되지 않은 경우 null을 반환합니다.
final aiModelInfoProvider = Provider<Map<String, dynamic>?>((ref) {
  final service = ref.watch(aiServiceProvider);
  return service.modelInfo;
});

// ============================================================================
// ModelManager 관련 프로바이더
// ============================================================================

/// 스캔된 모델 목록 프로바이더
/// 
/// ModelManager를 통해 디바이스에서 스캔한 모든 GGUF 모델 목록을 제공합니다.
/// 각 모델의 이름, 경로, 크기, 아키텍처, 양자화 정보를 포함합니다.
final scannedModelsProvider = FutureProvider<List<ModelInfo>>((ref) async {
  return await ModelManager.scanForModels();
});

/// 현재 선택된 모델 상태 관리 Notifier
class CurrentModelNotifier extends Notifier<ModelInfo?> {
  @override
  ModelInfo? build() => null;

  /// 모델 선택 업데이트
  void setModel(ModelInfo? model) {
    state = model;
  }

  /// 모델 선택 해제
  void clearModel() {
    state = null;
  }
}

/// 현재 선택된 모델 프로바이더
/// 
/// 사용자가 선택한 현재 AI 모델의 정보를 관리합니다.
/// null인 경우 선택된 모델이 없음을 의미합니다.
final currentModelProvider = NotifierProvider<CurrentModelNotifier, ModelInfo?>(
  CurrentModelNotifier.new,
);

/// 현재 선택된 모델 경로 프로바이더
/// 
/// SharedPreferences에 저장된 현재 모델 경로를 로드합니다.
final currentModelPathProvider = FutureProvider<String?>((ref) async {
  return await ModelManager.getCurrentModelPath();
});

/// 현재 선택된 모델 정보 프로바이더
/// 
/// SharedPreferences에 저장된 현재 모델의 전체 정보를 로드합니다.
final currentModelInfoProvider = FutureProvider<ModelInfo?>((ref) async {
  return await ModelManager.getCurrentModel();
});

/// 모델 선택 액션 프로바이더
/// 
/// 새로운 AI 모델을 선택하고 AI 서비스를 재초기화합니다.
/// 
/// 사용 예:
/// ```dart
/// final selectModel = ref.read(selectModelProvider);
/// await selectModel(modelPath);
/// ```
final selectModelProvider = Provider<Future<void> Function(String)>((ref) {
  return (String modelPath) async {
    // 1. SharedPreferences에 모델 경로 저장
    await ModelManager.setCurrentModel(modelPath);
    
    // 2. 현재 모델 상태 업데이트
    final models = await ModelManager.scanForModels();
    final selectedModel = models.firstWhere(
      (model) => model.path == modelPath,
      orElse: () => throw Exception('선택한 모델을 찾을 수 없습니다'),
    );
    ref.read(currentModelProvider.notifier).setModel(selectedModel);
    
    // 3. AI 서비스 재초기화
    final service = ref.read(aiServiceProvider);
    await service.reinitialize();
    
    // 4. 초기화 상태 프로바이더 갱신
    ref.invalidate(aiInitializationProvider);
  };
});

/// 저장소 권한 상태 프로바이더
/// 
/// 저장소 접근 권한이 있는지 확인합니다.
final storagePermissionProvider = FutureProvider<bool>((ref) async {
  return await ModelManager.requestStoragePermission();
});

/// AiModels 폴더 접근 테스트 프로바이더
/// 
/// AiModels 폴더에 대한 접근 권한과 상태를 테스트합니다.
/// 권한 상태, 폴더 존재 여부, 파일 목록 등의 정보를 제공합니다.
final aiModelsAccessTestProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ModelManager.testAiModelsAccess();
});

/// 모델 폴더 경로 프로바이더
/// 
/// AI 모델이 저장되는 폴더의 경로를 제공합니다.
final modelsDirectoryProvider = Provider<String>((ref) {
  return ModelManager.getModelsDirectory();
});

/// 권한 설정 가이드 프로바이더
/// 
/// 저장소 권한 설정 방법에 대한 가이드 텍스트를 제공합니다.
final permissionGuideProvider = Provider<String>((ref) {
  return ModelManager.getPermissionGuide();
});

// ============================================================================
// 디버그 정보 프로바이더
// ============================================================================

/// AI 서비스 디버그 정보 프로바이더
/// 
/// AI 서비스의 전체 디버그 정보를 제공합니다.
/// 초기화 상태, 모델 정보, 엔진 상태, 로그 등을 포함합니다.
final aiDebugInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(aiServiceProvider);
  return service.getDebugInfo();
});

/// AI 디버그 로그 프로바이더
/// 
/// AI 서비스의 디버그 로그 목록을 제공합니다.
final aiDebugLogsProvider = Provider<List<String>>((ref) {
  final service = ref.watch(aiServiceProvider);
  return service.debugLogs;
});

/// AI 초기화 시간 프로바이더
/// 
/// AI 서비스가 초기화된 시간을 제공합니다.
final aiInitializationTimeProvider = Provider<DateTime?>((ref) {
  final service = ref.watch(aiServiceProvider);
  return service.initializationTime;
});

/// AI 추론 엔진 상태 프로바이더
/// 
/// 현재 로드된 추론 엔진의 상태 정보를 제공합니다.
final aiEngineStatusProvider = Provider<Map<String, dynamic>?>((ref) {
  final service = ref.watch(aiServiceProvider);
  return service.engineStatus;
});

// ============================================================================
// 메모리 관리 프로바이더
// ============================================================================

/// AI 메모리 상태 프로바이더
/// 
/// AI 모델의 메모리 사용 상태를 제공합니다.
final aiMemoryStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(aiServiceProvider);
  return service.getMemoryStatus();
});

/// 모델 언로드 액션 프로바이더
/// 
/// 메모리 부족 시 AI 모델을 언로드합니다.
/// 
/// 사용 예:
/// ```dart
/// final unloadModel = ref.read(unloadModelProvider);
/// unloadModel();
/// ```
final unloadModelProvider = Provider<void Function()>((ref) {
  return () {
    final service = ref.read(aiServiceProvider);
    service.unloadModel();
    
    // 관련 프로바이더 무효화
    ref.invalidate(aiInitializationProvider);
    ref.invalidate(lazyAiInitializationProvider);
  };
});

// ============================================================================
// 배터리 최적화 프로바이더
// ============================================================================

/// 배터리 최적화 Notifier
class BatteryOptimizationNotifier extends Notifier<bool> {
  @override
  bool build() => true; // 기본값: 배터리 최적화 활성화
  
  void toggle(bool enabled) {
    state = enabled;
  }
}

/// 배터리 최적화 상태 프로바이더
/// 
/// 배터리 최적화 모드의 활성화 여부를 관리합니다.
final batteryOptimizationProvider = NotifierProvider<BatteryOptimizationNotifier, bool>(
  BatteryOptimizationNotifier.new,
);

/// 배터리 최적화 토글 액션
/// 
/// 배터리 최적화 모드를 켜거나 끕니다.
final toggleBatteryOptimizationProvider = Provider<void Function(bool)>((ref) {
  return (bool enabled) {
    ref.read(batteryOptimizationProvider.notifier).toggle(enabled);
    
    final service = ref.read(aiServiceProvider);
    service.setBatteryOptimization(enabled);
  };
});
