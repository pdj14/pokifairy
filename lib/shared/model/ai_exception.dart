import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// AI 에러 타입
enum AIErrorType {
  /// 모델을 찾을 수 없음
  modelNotFound,

  /// 모델 로드 실패
  modelLoadFailed,

  /// 추론 중 에러 발생
  inferenceError,

  /// 권한 거부됨
  permissionDenied,

  /// 메모리 부족
  insufficientMemory,

  /// 네트워크 에러
  networkError,

  /// 알 수 없는 에러
  unknown,
}

/// AI 관련 예외 클래스
class AIException implements Exception {
  final AIErrorType type;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AIException({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  /// 에러 타입에 따른 사용자 친화적 메시지 반환 (다국어 지원)
  String getUserFriendlyMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (type) {
      case AIErrorType.modelNotFound:
        return l10n.errorModelNotFound;
      case AIErrorType.modelLoadFailed:
        return l10n.errorModelLoadFailed;
      case AIErrorType.inferenceError:
        return l10n.errorInference;
      case AIErrorType.permissionDenied:
        return l10n.errorPermissionDenied;
      case AIErrorType.insufficientMemory:
        return l10n.errorInsufficientMemory;
      case AIErrorType.networkError:
        return l10n.errorNetwork;
      case AIErrorType.unknown:
        return l10n.errorUnknown;
    }
  }

  /// 에러 타입에 따른 사용자 친화적 메시지 반환 (한국어 - 폴백용)
  String get userFriendlyMessage {
    switch (type) {
      case AIErrorType.modelNotFound:
        return '사용 가능한 AI 모델이 없습니다. 모델을 다운로드해주세요.';
      case AIErrorType.modelLoadFailed:
        return 'AI 모델을 불러오는데 실패했습니다. 모델 파일을 확인해주세요.';
      case AIErrorType.inferenceError:
        return 'AI 응답 생성 중 오류가 발생했습니다. 다시 시도해주세요.';
      case AIErrorType.permissionDenied:
        return '저장소 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      case AIErrorType.insufficientMemory:
        return '메모리가 부족합니다. 다른 앱을 종료하고 다시 시도해주세요.';
      case AIErrorType.networkError:
        return '네트워크 연결을 확인해주세요.';
      case AIErrorType.unknown:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }

  /// 에러 타입에 따른 영어 메시지 반환 (폴백용)
  String get userFriendlyMessageEn {
    switch (type) {
      case AIErrorType.modelNotFound:
        return 'No AI model available. Please download a model.';
      case AIErrorType.modelLoadFailed:
        return 'Failed to load AI model. Please check the model file.';
      case AIErrorType.inferenceError:
        return 'Error occurred while generating AI response. Please try again.';
      case AIErrorType.permissionDenied:
        return 'Storage permission required. Please allow permission in settings.';
      case AIErrorType.insufficientMemory:
        return 'Insufficient memory. Please close other apps and try again.';
      case AIErrorType.networkError:
        return 'Please check your network connection.';
      case AIErrorType.unknown:
        return 'An unknown error occurred.';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('AIException($type): $message');
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    if (stackTrace != null) {
      buffer.write('\nStack trace:\n$stackTrace');
    }
    return buffer.toString();
  }

  /// 간단한 문자열 표현
  String toShortString() {
    return 'AIException($type): $message';
  }
}
