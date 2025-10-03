import 'package:flutter_test/flutter_test.dart';
import 'package:pokifairy/shared/model/ai_exception.dart';

void main() {
  group('AIErrorType', () {
    test('should have all expected error types', () {
      expect(AIErrorType.values.length, 7);
      expect(AIErrorType.values, contains(AIErrorType.modelNotFound));
      expect(AIErrorType.values, contains(AIErrorType.modelLoadFailed));
      expect(AIErrorType.values, contains(AIErrorType.inferenceError));
      expect(AIErrorType.values, contains(AIErrorType.permissionDenied));
      expect(AIErrorType.values, contains(AIErrorType.insufficientMemory));
      expect(AIErrorType.values, contains(AIErrorType.networkError));
      expect(AIErrorType.values, contains(AIErrorType.unknown));
    });
  });

  group('AIException', () {
    test('should create AIException with required fields', () {
      final exception = AIException(
        type: AIErrorType.modelNotFound,
        message: 'Model file not found',
      );

      expect(exception.type, AIErrorType.modelNotFound);
      expect(exception.message, 'Model file not found');
      expect(exception.originalError, null);
      expect(exception.stackTrace, null);
    });

    test('should create AIException with all fields', () {
      final originalError = Exception('Original error');
      final stackTrace = StackTrace.current;

      final exception = AIException(
        type: AIErrorType.inferenceError,
        message: 'Inference failed',
        originalError: originalError,
        stackTrace: stackTrace,
      );

      expect(exception.type, AIErrorType.inferenceError);
      expect(exception.message, 'Inference failed');
      expect(exception.originalError, originalError);
      expect(exception.stackTrace, stackTrace);
    });

    test('should return correct Korean user-friendly message for modelNotFound', () {
      final exception = AIException(
        type: AIErrorType.modelNotFound,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessage,
        '사용 가능한 AI 모델이 없습니다. 모델을 다운로드해주세요.',
      );
    });

    test('should return correct Korean user-friendly message for modelLoadFailed', () {
      final exception = AIException(
        type: AIErrorType.modelLoadFailed,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessage,
        'AI 모델을 불러오는데 실패했습니다. 모델 파일을 확인해주세요.',
      );
    });

    test('should return correct Korean user-friendly message for inferenceError', () {
      final exception = AIException(
        type: AIErrorType.inferenceError,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessage,
        'AI 응답 생성 중 오류가 발생했습니다. 다시 시도해주세요.',
      );
    });

    test('should return correct Korean user-friendly message for permissionDenied', () {
      final exception = AIException(
        type: AIErrorType.permissionDenied,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessage,
        '저장소 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
      );
    });

    test('should return correct Korean user-friendly message for insufficientMemory', () {
      final exception = AIException(
        type: AIErrorType.insufficientMemory,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessage,
        '메모리가 부족합니다. 다른 앱을 종료하고 다시 시도해주세요.',
      );
    });

    test('should return correct Korean user-friendly message for networkError', () {
      final exception = AIException(
        type: AIErrorType.networkError,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessage,
        '네트워크 연결을 확인해주세요.',
      );
    });

    test('should return correct Korean user-friendly message for unknown', () {
      final exception = AIException(
        type: AIErrorType.unknown,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessage,
        '알 수 없는 오류가 발생했습니다.',
      );
    });

    test('should return correct English user-friendly message for modelNotFound', () {
      final exception = AIException(
        type: AIErrorType.modelNotFound,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessageEn,
        'No AI model available. Please download a model.',
      );
    });

    test('should return correct English user-friendly message for modelLoadFailed', () {
      final exception = AIException(
        type: AIErrorType.modelLoadFailed,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessageEn,
        'Failed to load AI model. Please check the model file.',
      );
    });

    test('should return correct English user-friendly message for inferenceError', () {
      final exception = AIException(
        type: AIErrorType.inferenceError,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessageEn,
        'Error occurred while generating AI response. Please try again.',
      );
    });

    test('should return correct English user-friendly message for permissionDenied', () {
      final exception = AIException(
        type: AIErrorType.permissionDenied,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessageEn,
        'Storage permission required. Please allow permission in settings.',
      );
    });

    test('should return correct English user-friendly message for insufficientMemory', () {
      final exception = AIException(
        type: AIErrorType.insufficientMemory,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessageEn,
        'Insufficient memory. Please close other apps and try again.',
      );
    });

    test('should return correct English user-friendly message for networkError', () {
      final exception = AIException(
        type: AIErrorType.networkError,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessageEn,
        'Please check your network connection.',
      );
    });

    test('should return correct English user-friendly message for unknown', () {
      final exception = AIException(
        type: AIErrorType.unknown,
        message: 'Technical message',
      );

      expect(
        exception.userFriendlyMessageEn,
        'An unknown error occurred.',
      );
    });

    test('should have readable toString with basic info', () {
      final exception = AIException(
        type: AIErrorType.modelNotFound,
        message: 'Model not found',
      );

      final string = exception.toString();

      expect(string, contains('AIException'));
      expect(string, contains('modelNotFound'));
      expect(string, contains('Model not found'));
    });

    test('should include original error in toString', () {
      final originalError = Exception('Original error');
      final exception = AIException(
        type: AIErrorType.inferenceError,
        message: 'Inference failed',
        originalError: originalError,
      );

      final string = exception.toString();

      expect(string, contains('Original error:'));
      expect(string, contains('Original error'));
    });

    test('should include stack trace in toString', () {
      final stackTrace = StackTrace.current;
      final exception = AIException(
        type: AIErrorType.unknown,
        message: 'Unknown error',
        stackTrace: stackTrace,
      );

      final string = exception.toString();

      expect(string, contains('Stack trace:'));
    });

    test('should have short string representation', () {
      final exception = AIException(
        type: AIErrorType.networkError,
        message: 'Network failed',
      );

      final shortString = exception.toShortString();

      expect(shortString, 'AIException(AIErrorType.networkError): Network failed');
    });

    test('should not include original error in short string', () {
      final originalError = Exception('Original error');
      final exception = AIException(
        type: AIErrorType.inferenceError,
        message: 'Inference failed',
        originalError: originalError,
      );

      final shortString = exception.toShortString();

      expect(shortString, isNot(contains('Original error:')));
      expect(shortString, 'AIException(AIErrorType.inferenceError): Inference failed');
    });
  });
}
