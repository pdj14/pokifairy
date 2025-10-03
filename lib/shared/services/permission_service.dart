import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// 권한 관리 서비스
/// 
/// AI 모델 파일 접근을 위한 저장소 권한을 관리합니다.
class PermissionService {
  /// 저장소 권한 요청
  /// 
  /// Android와 iOS에서 각각 적절한 권한을 요청합니다.
  /// 
  /// Returns:
  /// - `true`: 권한이 허용됨
  /// - `false`: 권한이 거부됨
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      return await _requestAndroidStoragePermission();
    } else if (Platform.isIOS) {
      return await _requestIOSStoragePermission();
    }
    
    // 다른 플랫폼은 권한이 필요 없음
    return true;
  }

  /// Android 저장소 권한 요청
  static Future<bool> _requestAndroidStoragePermission() async {
    // Android 버전에 따라 다른 권한 요청
    if (await _getAndroidVersion() >= 33) {
      // Android 13+ (API 33+): 세분화된 미디어 권한
      final statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ].request();
      
      return statuses.values.every((status) => status.isGranted);
    } else if (await _getAndroidVersion() >= 30) {
      // Android 11-12 (API 30-32): MANAGE_EXTERNAL_STORAGE
      final status = await Permission.manageExternalStorage.request();
      
      if (status.isGranted) {
        return true;
      }
      
      // 폴백: 일반 저장소 권한
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else {
      // Android 10 이하: 일반 저장소 권한
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  /// iOS 저장소 권한 요청
  static Future<bool> _requestIOSStoragePermission() async {
    // iOS는 앱 샌드박스 내에서 파일 접근이 자유로우므로
    // 외부 파일 접근이 필요한 경우에만 권한 요청
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// 저장소 권한 상태 확인
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _getAndroidVersion() >= 33) {
        final statuses = await [
          Permission.photos.status,
          Permission.videos.status,
          Permission.audio.status,
        ].wait;
        
        return statuses.every((status) => status.isGranted);
      } else if (await _getAndroidVersion() >= 30) {
        final manageStatus = await Permission.manageExternalStorage.status;
        if (manageStatus.isGranted) {
          return true;
        }
        
        final storageStatus = await Permission.storage.status;
        return storageStatus.isGranted;
      } else {
        final status = await Permission.storage.status;
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.status;
      return status.isGranted;
    }
    
    return true;
  }

  /// 권한이 영구적으로 거부되었는지 확인
  static Future<bool> isPermissionPermanentlyDenied() async {
    if (Platform.isAndroid) {
      if (await _getAndroidVersion() >= 33) {
        final statuses = await [
          Permission.photos.status,
          Permission.videos.status,
          Permission.audio.status,
        ].wait;
        
        return statuses.any((status) => status.isPermanentlyDenied);
      } else if (await _getAndroidVersion() >= 30) {
        final manageStatus = await Permission.manageExternalStorage.status;
        final storageStatus = await Permission.storage.status;
        
        return manageStatus.isPermanentlyDenied || 
               storageStatus.isPermanentlyDenied;
      } else {
        final status = await Permission.storage.status;
        return status.isPermanentlyDenied;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.status;
      return status.isPermanentlyDenied;
    }
    
    return false;
  }

  /// 앱 설정 열기
  /// 
  /// 권한이 영구적으로 거부된 경우 사용자를 설정 화면으로 안내합니다.
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Android 버전 가져오기 (API 레벨)
  static Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) {
      return 0;
    }
    
    // permission_handler 패키지의 내부 구현을 사용하거나
    // device_info_plus 패키지를 사용할 수 있습니다.
    // 여기서는 간단히 최신 버전으로 가정
    return 33; // TODO: device_info_plus로 실제 버전 확인
  }

  /// 권한 요청 결과 메시지 생성
  static String getPermissionDeniedMessage() {
    if (Platform.isAndroid) {
      return 'AI 모델 파일에 접근하려면 저장소 권한이 필요합니다. '
          '설정에서 권한을 허용해주세요.';
    } else if (Platform.isIOS) {
      return 'AI 모델 파일에 접근하려면 사진 라이브러리 권한이 필요합니다. '
          '설정에서 권한을 허용해주세요.';
    }
    
    return '권한이 필요합니다.';
  }
}
