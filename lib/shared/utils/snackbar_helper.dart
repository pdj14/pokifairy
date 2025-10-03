import 'package:flutter/material.dart';

/// 스낵바 표시를 위한 헬퍼 함수들
/// 
/// 성공, 에러, 정보 메시지를 일관된 스타일로 표시합니다.
class SnackbarHelper {
  SnackbarHelper._();

  /// 성공 메시지 스낵바 표시
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: _getSuccessColor(context),
      duration: duration,
      action: action,
    );
  }

  /// 에러 메시지 스낵바 표시
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: _getErrorColor(context),
      duration: duration,
      action: action,
    );
  }

  /// 정보 메시지 스낵바 표시
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: _getInfoColor(context),
      duration: duration,
      action: action,
    );
  }

  /// 경고 메시지 스낵바 표시
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: Icons.warning_amber_outlined,
      backgroundColor: _getWarningColor(context),
      duration: duration,
      action: action,
    );
  }

  /// 기본 스낵바 표시 (커스텀 아이콘 및 색상)
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      icon: icon,
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
    );
  }

  /// 내부 스낵바 표시 로직
  static void _showSnackbar(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    required Duration duration,
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 기존 스낵바 제거
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: _getContentColor(backgroundColor, colorScheme),
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getContentColor(backgroundColor, colorScheme),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? colorScheme.primaryContainer,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      action: action,
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 성공 색상 가져오기
  static Color _getSuccessColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return colorScheme.tertiary;
  }

  /// 에러 색상 가져오기
  static Color _getErrorColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return colorScheme.errorContainer;
  }

  /// 정보 색상 가져오기
  static Color _getInfoColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return colorScheme.primaryContainer;
  }

  /// 경고 색상 가져오기
  static Color _getWarningColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return colorScheme.secondaryContainer;
  }

  /// 콘텐츠 색상 가져오기 (배경색에 따라)
  static Color _getContentColor(Color? backgroundColor, ColorScheme colorScheme) {
    if (backgroundColor == null) {
      return colorScheme.onPrimaryContainer;
    }

    // 배경색의 밝기에 따라 텍스트 색상 결정
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// 스낵바 액션 빌더 헬퍼
class SnackbarActionBuilder {
  SnackbarActionBuilder._();

  /// 재시도 액션
  static SnackBarAction retry(
    BuildContext context,
    VoidCallback onPressed, {
    String? label,
  }) {
    return SnackBarAction(
      label: label ?? 'Retry', // TODO: localize
      onPressed: onPressed,
      textColor: Theme.of(context).colorScheme.primary,
    );
  }

  /// 실행 취소 액션
  static SnackBarAction undo(
    BuildContext context,
    VoidCallback onPressed, {
    String? label,
  }) {
    return SnackBarAction(
      label: label ?? 'Undo', // TODO: localize
      onPressed: onPressed,
      textColor: Theme.of(context).colorScheme.primary,
    );
  }

  /// 보기 액션
  static SnackBarAction view(
    BuildContext context,
    VoidCallback onPressed, {
    String? label,
  }) {
    return SnackBarAction(
      label: label ?? 'View', // TODO: localize
      onPressed: onPressed,
      textColor: Theme.of(context).colorScheme.primary,
    );
  }

  /// 커스텀 액션
  static SnackBarAction custom(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return SnackBarAction(
      label: label,
      onPressed: onPressed,
      textColor: Theme.of(context).colorScheme.primary,
    );
  }
}
