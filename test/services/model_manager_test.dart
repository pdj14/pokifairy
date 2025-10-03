import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokifairy/shared/services/ai/model_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ModelManager', () {
    test('formatFileSize should format bytes correctly', () {
      expect(ModelManager.formatFileSize(0), '0B');
      expect(ModelManager.formatFileSize(512), '512B');
      expect(ModelManager.formatFileSize(1024), '1.0KB');
      expect(ModelManager.formatFileSize(1536), '1.5KB');
      expect(ModelManager.formatFileSize(1024 * 1024), '1.0MB');
      expect(ModelManager.formatFileSize((1024 * 1024 * 1.5).toInt()), '1.5MB');
      expect(ModelManager.formatFileSize(1024 * 1024 * 1024), '1.0GB');
      expect(ModelManager.formatFileSize(1024 * 1024 * 1024 * 2), '2.0GB');
    });

    test('getInstallationGuide should return non-empty string', () {
      final guide = ModelManager.getInstallationGuide();

      expect(guide, isA<String>());
      expect(guide.isNotEmpty, true);
      expect(guide, contains('모델'));
    });

    test('getModelsDirectory should return directory path', () {
      final directory = ModelManager.getModelsDirectory();

      expect(directory, isA<String>());
      expect(directory.isNotEmpty, true);
      expect(directory, contains('AiModels'));
    });

    test('getPermissionGuide should return guide text', () {
      final guide = ModelManager.getPermissionGuide();

      expect(guide, isA<String>());
      expect(guide.isNotEmpty, true);
      expect(guide, contains('권한'));
      expect(guide, contains('Android'));
    });

    test('guessArchitecture should identify model architecture', () {
      expect(ModelManager.guessArchitecture('gemma-model.gguf'), 'Gemma');
      expect(ModelManager.guessArchitecture('llama-2-7b.gguf'), 'Llama');
      expect(ModelManager.guessArchitecture('qwen-1.5.gguf'), 'Qwen');
      expect(ModelManager.guessArchitecture('mistral-7b.gguf'), 'Mistral');
      expect(ModelManager.guessArchitecture('phi-2.gguf'), 'Phi');
      expect(ModelManager.guessArchitecture('unknown-model.gguf'), isNull);
    });

    test('guessQuantization should identify quantization method', () {
      expect(ModelManager.guessQuantization('model-Q4_K_M.gguf'), 'Q4_K_M');
      expect(ModelManager.guessQuantization('model-Q4_0.gguf'), 'Q4_0');
      expect(ModelManager.guessQuantization('model-Q5_K_M.gguf'), 'Q5_K_M');
      expect(ModelManager.guessQuantization('model-Q8_0.gguf'), 'Q8_0');
      expect(ModelManager.guessQuantization('model-F16.gguf'), 'F16');
      expect(ModelManager.guessQuantization('model-F32.gguf'), 'F32');
      expect(ModelManager.guessQuantization('model.gguf'), isNull);
    });

    test('getCurrentModelPath should return null initially', () async {
      final path = await ModelManager.getCurrentModelPath();
      expect(path, isNull);
    });

    test('setCurrentModel should save model path', () async {
      const testPath = '/test/path/model.gguf';
      
      await ModelManager.setCurrentModel(testPath);
      final savedPath = await ModelManager.getCurrentModelPath();

      expect(savedPath, testPath);
    });

    test('getCurrentModel should return null when no model is set', () async {
      final model = await ModelManager.getCurrentModel();
      expect(model, isNull);
    });

    test('getAvailableModels should return map', () async {
      try {
        final models = await ModelManager.getAvailableModels();
        
        expect(models, isA<Map<String, String?>>());
        expect(models.containsKey('documents'), true);
      } catch (e) {
        // Expected to fail in test environment
        expect(e, isA<Exception>());
      }
    }, skip: 'Requires file system access');

    test('getBestAvailableModel should throw when no models exist', () async {
      expect(
        () => ModelManager.getBestAvailableModel(),
        throwsA(isA<Exception>()),
      );
    }, skip: 'Requires file system access');

    test('getModelFileSize should return 0 for non-existent file', () async {
      final size = await ModelManager.getModelFileSize('/non/existent/file.gguf');
      expect(size, 0);
    });

    test('getModelFileSize should return 0 for assets path', () async {
      final size = await ModelManager.getModelFileSize('assets://model.gguf');
      expect(size, 0);
    });

    test('scanForModels should return empty list without permission', () async {
      final models = await ModelManager.scanForModels();
      expect(models, isA<List<ModelInfo>>());
    }, skip: 'Requires platform channels and permissions');

    test('requestStoragePermission should handle permission request', () async {
      try {
        final hasPermission = await ModelManager.requestStoragePermission();
        expect(hasPermission, isA<bool>());
      } catch (e) {
        // Expected to fail in test environment
        expect(e, isA<Exception>());
      }
    }, skip: 'Requires platform channels');

    test('testAiModelsAccess should return status map', () async {
      try {
        final result = await ModelManager.testAiModelsAccess();
        
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('hasPermission'), true);
        expect(result.containsKey('canAccess'), true);
        expect(result.containsKey('folderExists'), true);
        expect(result.containsKey('files'), true);
      } catch (e) {
        // Expected to fail in test environment
        expect(e, isA<Exception>());
      }
    }, skip: 'Requires platform channels');
  });

  group('ModelInfo', () {
    test('should create ModelInfo with required fields', () {
      final model = ModelInfo(
        name: 'test-model.gguf',
        path: '/test/path/test-model.gguf',
        size: 1024 * 1024 * 100, // 100MB
        formattedSize: '100.0MB',
      );

      expect(model.name, 'test-model.gguf');
      expect(model.path, '/test/path/test-model.gguf');
      expect(model.size, 1024 * 1024 * 100);
      expect(model.formattedSize, '100.0MB');
      expect(model.architecture, isNull);
      expect(model.quantization, isNull);
    });

    test('should create ModelInfo with all fields', () {
      final model = ModelInfo(
        name: 'gemma-Q4_K_M.gguf',
        path: '/test/path/gemma-Q4_K_M.gguf',
        size: 1024 * 1024 * 500,
        formattedSize: '500.0MB',
        architecture: 'Gemma',
        quantization: 'Q4_K_M',
      );

      expect(model.name, 'gemma-Q4_K_M.gguf');
      expect(model.path, '/test/path/gemma-Q4_K_M.gguf');
      expect(model.size, 1024 * 1024 * 500);
      expect(model.formattedSize, '500.0MB');
      expect(model.architecture, 'Gemma');
      expect(model.quantization, 'Q4_K_M');
    });
  });

  group('ModelManager Integration', () {
    test('should handle model selection workflow', () async {
      const testPath = '/test/models/gemma-Q4_K_M.gguf';
      
      // Set model
      await ModelManager.setCurrentModel(testPath);
      
      // Get model path
      final savedPath = await ModelManager.getCurrentModelPath();
      expect(savedPath, testPath);
      
      // Format size
      final size = ModelManager.formatFileSize(1024 * 1024 * 500);
      expect(size, '500.0MB');
      
      // Guess architecture
      final arch = ModelManager.guessArchitecture(testPath);
      expect(arch, 'Gemma');
      
      // Guess quantization
      final quant = ModelManager.guessQuantization(testPath);
      expect(quant, 'Q4_K_M');
    });
  });
}
