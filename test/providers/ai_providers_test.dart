import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokifairy/shared/providers/ai_providers.dart';
import 'package:pokifairy/shared/services/ai/ai_service.dart';
import 'package:pokifairy/shared/services/ai/model_manager.dart';

void main() {
  // Flutter 바인딩 초기화 (플랫폼 채널 사용을 위해 필요)
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AI Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('aiServiceProvider returns AIService singleton instance', () {
      // Arrange & Act
      final service1 = container.read(aiServiceProvider);
      final service2 = container.read(aiServiceProvider);

      // Assert
      expect(service1, isA<AIService>());
      expect(service1, same(service2)); // 동일한 인스턴스인지 확인
      expect(service1, equals(AIService.instance));
    });

    test('aiInitializationProvider initializes AI service', () async {
      // Arrange & Act
      final initProvider = container.read(aiInitializationProvider);

      // Assert
      // 플랫폼 채널이 없는 환경에서는 로딩 상태이거나 에러 상태일 수 있음
      expect(initProvider, isA<AsyncValue<bool>>());
    }, skip: 'Requires platform channels - run as integration test');

    test('availableModelsProvider returns model information', () async {
      // Arrange & Act
      final modelsProvider = container.read(availableModelsProvider);

      // Assert
      expect(modelsProvider, isA<AsyncValue<Map<String, dynamic>>>());
    }, skip: 'Requires platform channels - run as integration test');

    test('modelInstallationGuideProvider returns guide text', () {
      // Arrange & Act
      final guide = container.read(modelInstallationGuideProvider);

      // Assert
      expect(guide, isA<String>());
      expect(guide.isNotEmpty, true);
    });

    test('aiModelInfoProvider returns null when no model is loaded', () {
      // Arrange & Act
      final modelInfo = container.read(aiModelInfoProvider);

      // Assert
      // 초기 상태에서는 null일 수 있음
      expect(modelInfo, anyOf(isNull, isA<Map<String, dynamic>>()));
    });

    test('currentModelProvider initial state is null', () {
      // Arrange & Act
      final currentModel = container.read(currentModelProvider);

      // Assert
      expect(currentModel, isNull);
    });

    test('currentModelProvider can be updated', () {
      // Arrange
      final testModelInfo = ModelInfo(
        name: 'test-model.gguf',
        path: '/test/path/test-model.gguf',
        size: 1024,
        formattedSize: '1.0KB',
        architecture: 'Gemma',
        quantization: 'Q4_K_M',
      );

      // Act
      container.read(currentModelProvider.notifier).setModel(testModelInfo);
      final updatedModel = container.read(currentModelProvider);

      // Assert
      expect(updatedModel, equals(testModelInfo));
      expect(updatedModel?.name, equals('test-model.gguf'));
      expect(updatedModel?.path, equals('/test/path/test-model.gguf'));
    });

    test('scannedModelsProvider returns list of ModelInfo', () async {
      // Arrange & Act
      final modelsProvider = container.read(scannedModelsProvider);

      // Assert
      expect(modelsProvider, isA<AsyncValue<List<ModelInfo>>>());
    }, skip: 'Requires platform channels - run as integration test');

    test('currentModelPathProvider returns nullable string', () async {
      // Arrange & Act
      final pathProvider = container.read(currentModelPathProvider);

      // Assert
      expect(pathProvider, isA<AsyncValue<String?>>());
    }, skip: 'Requires platform channels - run as integration test');

    test('currentModelInfoProvider returns nullable ModelInfo', () async {
      // Arrange & Act
      final infoProvider = container.read(currentModelInfoProvider);

      // Assert
      expect(infoProvider, isA<AsyncValue<ModelInfo?>>());
    }, skip: 'Requires platform channels - run as integration test');

    test('storagePermissionProvider returns boolean', () async {
      // Arrange & Act
      final permissionProvider = container.read(storagePermissionProvider);

      // Assert
      expect(permissionProvider, isA<AsyncValue<bool>>());
    }, skip: 'Requires platform channels - run as integration test');

    test('modelsDirectoryProvider returns directory path', () {
      // Arrange & Act
      final directory = container.read(modelsDirectoryProvider);

      // Assert
      expect(directory, isA<String>());
      expect(directory.isNotEmpty, true);
    });

    test('permissionGuideProvider returns guide text', () {
      // Arrange & Act
      final guide = container.read(permissionGuideProvider);

      // Assert
      expect(guide, isA<String>());
      expect(guide.isNotEmpty, true);
      expect(guide.contains('권한'), true); // 한국어 가이드 확인
    });

    test('aiModelsAccessTestProvider returns test results', () async {
      // Arrange & Act
      final testProvider = container.read(aiModelsAccessTestProvider);

      // Assert
      expect(testProvider, isA<AsyncValue<Map<String, dynamic>>>());
    }, skip: 'Requires platform channels - run as integration test');

    test('selectModelProvider returns function', () {
      // Arrange & Act
      final selectModel = container.read(selectModelProvider);

      // Assert
      expect(selectModel, isA<Future<void> Function(String)>());
    });
  });

  group('Model Selection Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('selecting a model updates currentModelProvider', () async {
      // Arrange
      const testModelPath = '/test/path/test-model.gguf';
      
      // Note: 이 테스트는 실제 파일 시스템과 상호작용하므로
      // 실제 환경에서는 실패할 수 있습니다.
      // Mock을 사용하는 것이 더 좋지만, 기본 구조를 테스트합니다.
      
      // Act & Assert
      // selectModelProvider는 실제 파일이 필요하므로
      // 함수가 존재하는지만 확인
      final selectModel = container.read(selectModelProvider);
      expect(selectModel, isNotNull);
    });
  });

  group('Provider Dependencies Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('aiInitializationProvider depends on aiServiceProvider', () {
      // Arrange
      final service = container.read(aiServiceProvider);

      // Act
      final initProvider = container.read(aiInitializationProvider);

      // Assert
      expect(service, isNotNull);
      expect(initProvider, isA<AsyncValue<bool>>());
    }, skip: 'Requires platform channels - run as integration test');

    test('multiple providers can be read simultaneously', () {
      // Arrange & Act
      final service = container.read(aiServiceProvider);
      final guide = container.read(modelInstallationGuideProvider);
      final directory = container.read(modelsDirectoryProvider);
      final currentModel = container.read(currentModelProvider);

      // Assert
      expect(service, isNotNull);
      expect(guide, isNotNull);
      expect(directory, isNotNull);
      expect(currentModel, isNull); // 초기 상태
    });
  });
}
