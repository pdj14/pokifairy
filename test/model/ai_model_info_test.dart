import 'package:flutter_test/flutter_test.dart';
import 'package:pokifairy/shared/model/ai_model_info.dart';

void main() {
  group('AIModelInfo', () {
    test('should create AIModelInfo with required fields', () {
      final modelInfo = AIModelInfo(
        name: 'Gemma 2B',
        path: '/path/to/model.gguf',
        sizeBytes: 2147483648, // 2 GB
        architecture: 'gemma',
        isValid: true,
      );

      expect(modelInfo.name, 'Gemma 2B');
      expect(modelInfo.path, '/path/to/model.gguf');
      expect(modelInfo.sizeBytes, 2147483648);
      expect(modelInfo.architecture, 'gemma');
      expect(modelInfo.isValid, true);
      expect(modelInfo.metadata, null);
    });

    test('should create AIModelInfo with metadata', () {
      final metadata = {
        'version': '1.0',
        'quantization': 'Q4_K_M',
      };

      final modelInfo = AIModelInfo(
        name: 'Llama 3',
        path: '/path/to/llama.gguf',
        sizeBytes: 4294967296, // 4 GB
        architecture: 'llama',
        isValid: true,
        metadata: metadata,
      );

      expect(modelInfo.metadata, metadata);
      expect(modelInfo.metadata?['version'], '1.0');
      expect(modelInfo.metadata?['quantization'], 'Q4_K_M');
    });

    test('should format size in bytes correctly', () {
      final modelInfo = AIModelInfo(
        name: 'Test',
        path: '/test',
        sizeBytes: 512,
        architecture: 'test',
        isValid: true,
      );

      expect(modelInfo.formattedSize, '512 B');
    });

    test('should format size in KB correctly', () {
      final modelInfo = AIModelInfo(
        name: 'Test',
        path: '/test',
        sizeBytes: 2048, // 2 KB
        architecture: 'test',
        isValid: true,
      );

      expect(modelInfo.formattedSize, '2.00 KB');
    });

    test('should format size in MB correctly', () {
      final modelInfo = AIModelInfo(
        name: 'Test',
        path: '/test',
        sizeBytes: 10485760, // 10 MB
        architecture: 'test',
        isValid: true,
      );

      expect(modelInfo.formattedSize, '10.00 MB');
    });

    test('should format size in GB correctly', () {
      final modelInfo = AIModelInfo(
        name: 'Test',
        path: '/test',
        sizeBytes: 2147483648, // 2 GB
        architecture: 'test',
        isValid: true,
      );

      expect(modelInfo.formattedSize, '2.00 GB');
    });

    test('should serialize to JSON correctly', () {
      final modelInfo = AIModelInfo(
        name: 'Test Model',
        path: '/models/test.gguf',
        sizeBytes: 1073741824, // 1 GB
        architecture: 'llama',
        isValid: true,
        metadata: {'key': 'value'},
      );

      final json = modelInfo.toJson();

      expect(json['name'], 'Test Model');
      expect(json['path'], '/models/test.gguf');
      expect(json['sizeBytes'], 1073741824);
      expect(json['architecture'], 'llama');
      expect(json['isValid'], true);
      expect(json['metadata'], {'key': 'value'});
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'name': 'Deserialized Model',
        'path': '/models/deserialized.gguf',
        'sizeBytes': 536870912, // 512 MB
        'architecture': 'gemma',
        'isValid': false,
        'metadata': {'error': 'corrupted'},
      };

      final modelInfo = AIModelInfo.fromJson(json);

      expect(modelInfo.name, 'Deserialized Model');
      expect(modelInfo.path, '/models/deserialized.gguf');
      expect(modelInfo.sizeBytes, 536870912);
      expect(modelInfo.architecture, 'gemma');
      expect(modelInfo.isValid, false);
      expect(modelInfo.metadata, {'error': 'corrupted'});
    });

    test('should handle missing metadata in JSON', () {
      final json = {
        'name': 'Minimal Model',
        'path': '/models/minimal.gguf',
        'sizeBytes': 1024,
        'architecture': 'test',
        'isValid': true,
      };

      final modelInfo = AIModelInfo.fromJson(json);

      expect(modelInfo.name, 'Minimal Model');
      expect(modelInfo.metadata, null);
    });

    test('should create copy with updated fields', () {
      final original = AIModelInfo(
        name: 'Original',
        path: '/original',
        sizeBytes: 1024,
        architecture: 'test',
        isValid: false,
      );

      final updated = original.copyWith(
        name: 'Updated',
        isValid: true,
      );

      expect(updated.name, 'Updated');
      expect(updated.path, original.path);
      expect(updated.sizeBytes, original.sizeBytes);
      expect(updated.architecture, original.architecture);
      expect(updated.isValid, true);
    });

    test('should maintain equality for same content', () {
      final modelInfo1 = AIModelInfo(
        name: 'Same Model',
        path: '/same/path',
        sizeBytes: 2048,
        architecture: 'llama',
        isValid: true,
      );

      final modelInfo2 = AIModelInfo(
        name: 'Same Model',
        path: '/same/path',
        sizeBytes: 2048,
        architecture: 'llama',
        isValid: true,
      );

      expect(modelInfo1, equals(modelInfo2));
      expect(modelInfo1.hashCode, equals(modelInfo2.hashCode));
    });

    test('should not be equal for different content', () {
      final modelInfo1 = AIModelInfo(
        name: 'Model 1',
        path: '/path1',
        sizeBytes: 1024,
        architecture: 'llama',
        isValid: true,
      );

      final modelInfo2 = AIModelInfo(
        name: 'Model 2',
        path: '/path2',
        sizeBytes: 2048,
        architecture: 'gemma',
        isValid: true,
      );

      expect(modelInfo1, isNot(equals(modelInfo2)));
    });

    test('should have readable toString', () {
      final modelInfo = AIModelInfo(
        name: 'Test Model',
        path: '/models/test.gguf',
        sizeBytes: 1073741824,
        architecture: 'llama',
        isValid: true,
      );

      final string = modelInfo.toString();

      expect(string, contains('AIModelInfo'));
      expect(string, contains('name: Test Model'));
      expect(string, contains('path: /models/test.gguf'));
      expect(string, contains('architecture: llama'));
      expect(string, contains('isValid: true'));
      expect(string, contains('1.00 GB'));
    });

    test('should handle very large file sizes', () {
      final modelInfo = AIModelInfo(
        name: 'Large Model',
        path: '/large',
        sizeBytes: 10737418240, // 10 GB
        architecture: 'test',
        isValid: true,
      );

      expect(modelInfo.formattedSize, '10.00 GB');
    });

    test('should handle zero size', () {
      final modelInfo = AIModelInfo(
        name: 'Empty',
        path: '/empty',
        sizeBytes: 0,
        architecture: 'test',
        isValid: false,
      );

      expect(modelInfo.formattedSize, '0 B');
    });
  });
}
