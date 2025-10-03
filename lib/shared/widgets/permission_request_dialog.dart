import 'dart:async';
import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../../l10n/app_localizations.dart';

/// 권한 요청 다이얼로그
/// 
/// 저장소 권한이 필요한 경우 사용자에게 권한 요청 다이얼로그를 표시합니다.
class PermissionRequestDialog extends StatelessWidget {
  const PermissionRequestDialog({
    super.key,
    this.title,
    this.message,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  final String? title;
  final String? message;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(title ?? l10n.permissionDialogTitle),
      content: Text(
        message ?? l10n.permissionDialogMessage,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPermissionDenied?.call();
          },
          child: Text(l10n.permissionDialogCancel),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            
            final granted = await PermissionService.requestStoragePermission();
            
            if (granted) {
              onPermissionGranted?.call();
            } else {
              // 권한이 거부된 경우
              final permanentlyDenied = 
                  await PermissionService.isPermissionPermanentlyDenied();
              
              if (permanentlyDenied && context.mounted) {
                // 영구적으로 거부된 경우 설정으로 이동
                _showSettingsDialog(context);
              } else {
                onPermissionDenied?.call();
              }
            }
          },
          child: Text(l10n.permissionDialogAllow),
        ),
      ],
    );
  }

  /// 설정 화면으로 이동하는 다이얼로그 표시
  void _showSettingsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionSettingsTitle),
        content: Text(l10n.permissionSettingsMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onPermissionDenied?.call();
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await PermissionService.openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  /// 권한 요청 다이얼로그 표시 헬퍼 메서드
  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final completer = Completer<bool>();

    await showDialog(
      context: context,
      builder: (context) => PermissionRequestDialog(
        title: title,
        message: message,
        onPermissionGranted: () => completer.complete(true),
        onPermissionDenied: () => completer.complete(false),
      ),
    );

    return completer.future;
  }
}

/// 권한 체크 및 요청 헬퍼 함수
/// 
/// 권한이 없는 경우 자동으로 다이얼로그를 표시하고 권한을 요청합니다.
/// 
/// Returns:
/// - `true`: 권한이 허용됨
/// - `false`: 권한이 거부됨
Future<bool> checkAndRequestStoragePermission(BuildContext context) async {
  // 이미 권한이 있는지 확인
  final hasPermission = await PermissionService.checkStoragePermission();
  
  if (hasPermission) {
    return true;
  }

  // 권한이 없으면 다이얼로그 표시
  if (!context.mounted) {
    return false;
  }

  return await PermissionRequestDialog.show(context);
}
