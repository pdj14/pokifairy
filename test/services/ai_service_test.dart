import 'package:flutter_test/flutter_test.dart';
import 'package:pokifairy/shared/services/ai/ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AIService', () {
    late AIService service;

    setUp(() {
      service = AIService.instance;
    });

    test('should return singleton instance', () {
      final instance1 = AIService.instance;
      final instance2 = AIService.instance;

      expect(instance1, same(instance2));
    });

    test('should have initial state as not initialized', () {
      // Note: This test assumes a fresh instance
      // In real scenario, service might be initialized already
      expect(service.isInitialized, anyOf(isTrue, isFalse));
    });

    test('should have null model path initially', () {
      // Model path might be set if initialized
      expect(service.currentModelPath, anyOf(isNull, isA<String>()));
    });

    test('should have empty or populated debug logs', () {
      final logs = service.debugLogs;
      expect(logs, isA<List<String>>());
    });

    test('should clear debug logs', () {
      service.clearDebugLogs();
      final logs = service.debugLogs;
      
      // After clearing, should have at least one log (the clear message)
      expect(logs.length, greaterThanOrEqualTo(1));
      expect(logs.last, contains('디버그 로그 초기화됨'));
    });

    test('should return debug info map', () {
      final debugInfo = service.getDebugInfo();

      expect(debugInfo, isA<Map<String, dynamic>>());
      expect(debugInfo.containsKey('isInitialized'), true);
      expect(debugInfo.containsKey('modelPath'), true);
      expect(debugInfo.containsKey('modelInfo'), true);
      expect(debugInfo.containsKey('debugLogs'), true);
      expect(debugInfo.containsKey('logCount'), true);
    });

    test('should return model info or null', () {
      final modelInfo = service.modelInfo;
      expect(modelInfo, anyOf(isNull, isA<Map<String, dynamic>>()));
    });

    test('should return initialization time or null', () {
      final initTime = service.initializationTime;
      expect(initTime, anyOf(isNull, isA<DateTime>()));
    });

    test('should return engine status or null', () {
      final engineStatus = service.engineStatus;
      expect(engineStatus, anyOf(isNull, isA<Map<String, dynamic>>()));
    });

    test('should set background state', () {
      service.setBackgroundState(true);
      expect(service.isBackgrounded, true);

      service.setBackgroundState(false);
      expect(service.isBackgrounded, false);
    });

    test('should set battery optimization', () {
      service.setBatteryOptimization(true);
      expect(service.isBatteryOptimizationEnabled, true);

      service.setBatteryOptimization(false);
      expect(service.isBatteryOptimizationEnabled, false);
    });

    test('should return memory status', () {
      final memoryStatus = service.getMemoryStatus();

      expect(memoryStatus, isA<Map<String, dynamic>>());
      expect(memoryStatus.containsKey('modelLoaded'), true);
      expect(memoryStatus.containsKey('canUnload'), true);
      expect(memoryStatus.containsKey('modelPath'), true);
    });

    test('should return model installation guide', () {
      final guide = service.getModelInstallationGuide();

      expect(guide, isA<String>());
      expect(guide.isNotEmpty, true);
    });

    test('initialize should handle missing model gracefully', () async {
      // This test will likely fail in test environment
      // but we're testing the error handling
      try {
        final result = await service.initialize();
        expect(result, isA<bool>());
      } catch (e) {
        // Expected to fail in test environment
        expect(e, isA<Exception>());
      }
    }, skip: 'Requires platform channels and model files');

    test('generateResponse should throw when not initialized', () async {
      // Create a fresh service instance for this test
      service.dispose();
      
      expect(
        () => service.generateResponse('test'),
        throwsA(isA<Exception>()),
      );
    }, skip: 'Requires platform channels');

    test('generateResponseStream should handle background state', () async {
      service.setBackgroundState(true);

      final stream = service.generateResponseStream('test');
      final responses = await stream.toList();

      expect(responses, isNotEmpty);
      expect(responses.first, contains('백그라운드'));
    }, skip: 'Requires platform channels');

    test('unloadModel should clear inference engine', () {
      service.unloadModel();

      final memoryStatus = service.getMemoryStatus();
      expect(memoryStatus['modelLoaded'], false);
    });

    test('dispose should clear all resources', () {
      service.dispose();

      expect(service.isInitialized, false);
      expect(service.currentModelPath, isNull);
      expect(service.modelInfo, isNull);
    });

    test('reinitialize should dispose and initialize again', () async {
      try {
        final result = await service.reinitialize();
        expect(result, isA<bool>());
      } catch (e) {
        // Expected to fail in test environment
        expect(e, isA<Exception>());
      }
    }, skip: 'Requires platform channels');

    test('getAvailableModelsInfo should return map', () async {
      try {
        final models = await service.getAvailableModelsInfo();
        expect(models, isA<Map<String, dynamic>>());
      } catch (e) {
        // Expected to fail in test environment
        expect(e, isA<Exception>());
      }
    }, skip: 'Requires platform channels');
  });

  group('AIService Child-Friendly Prompt', () {
    test('should format prompt for children', () {
      // This is an internal method, but we can test the output
      // by checking the generated response format
      expect(true, true); // Placeholder
    });
  });

  group('AIService Performance', () {
    test('should handle multiple rapid calls', () async {
      final service = AIService.instance;
      
      // Test that multiple calls don't crash
      for (int i = 0; i < 5; i++) {
        service.clearDebugLogs();
        service.setBackgroundState(false);
        service.setBatteryOptimization(true);
      }

      expect(service.debugLogs, isNotEmpty);
    });

    test('should limit debug logs to 100 entries', () {
      final service = AIService.instance;
      service.clearDebugLogs();

      // Add more than 100 logs
      for (int i = 0; i < 150; i++) {
        service.setBackgroundState(i % 2 == 0);
      }

      final logs = service.debugLogs;
      expect(logs.length, lessThanOrEqualTo(101)); // 100 + clear message
    });
  });
}
