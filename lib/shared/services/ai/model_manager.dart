import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

/// AI 모델 정보를 담는 데이터 클래스
/// 
/// GGUF 모델 파일의 메타데이터를 표현합니다.
/// 
/// Properties:
///   - `name`: 모델 파일명
///   - `path`: 모델 파일의 전체 경로
///   - `size`: 파일 크기 (바이트)
///   - `formattedSize`: 사람이 읽기 쉬운 형식의 파일 크기 (예: "1.5GB")
///   - `architecture`: 모델 아키텍처 (예: "Gemma", "Llama")
///   - `quantization`: 양자화 방식 (예: "Q4_K_M", "Q8_0")
class ModelInfo {
  final String name;
  final String path;
  final int size;
  final String formattedSize;
  final String? architecture;
  final String? quantization;

  ModelInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.formattedSize,
    this.architecture,
    this.quantization,
  });
}

/// AI 모델 관리 서비스
/// 
/// GGUF 형식의 AI 모델을 검색, 선택, 관리하는 유틸리티 클래스입니다.
/// 
/// 주요 기능:
/// - 디바이스에서 사용 가능한 모델 검색
/// - 모델 파일 크기 및 메타데이터 조회
/// - 현재 선택된 모델 관리
/// - 저장소 권한 처리
/// - 모델 설치 가이드 제공
/// 
/// 지원하는 모델 위치:
/// - Android: `/storage/emulated/0/AiModels/`, `/storage/emulated/0/Download/`
/// - iOS: App Documents 디렉토리
/// 
/// 사용 예:
/// ```dart
/// // 사용 가능한 모델 검색
/// final models = await ModelManager.scanForModels();
/// 
/// // 모델 선택
/// await ModelManager.setCurrentModel(models.first.path);
/// 
/// // 현재 모델 조회
/// final currentModel = await ModelManager.getCurrentModel();
/// ```
class ModelManager {
  static const String largeModelFileName = 'gemma-3n-E2B-it-Q4_K_M.gguf';
  static const String _currentModelKey = 'current_model_path';
  
  /// 디바이스에서 사용 가능한 모든 모델 경로를 검색합니다.
  /// 
  /// 여러 위치를 스캔하여 GGUF 모델 파일을 찾습니다:
  /// - Documents 폴더
  /// - 외부 저장소 (Android)
  /// - Download 폴더 (Android)
  /// - AiModels 폴더 (Android)
  /// 
  /// Returns:
  ///   - `Map<String, String?>`: 위치 이름과 모델 경로의 맵
  ///     - Key: 위치 식별자 ('documents', 'download', 'aimodels' 등)
  ///     - Value: 모델 파일 경로 (없으면 null)
  /// 
  /// 사용 예:
  /// ```dart
  /// final models = await ModelManager.getAvailableModels();
  /// if (models['download'] != null) {
  ///   print('Download 폴더에 모델 발견: ${models['download']}');
  /// }
  /// ```
  static Future<Map<String, String?>> getAvailableModels() async {
    final paths = <String, String?>{};
    
    // 1. 앱 Documents 폴더
    final documentsDir = await getApplicationDocumentsDirectory();
    final documentsModelPath = '${documentsDir.path}/models/$largeModelFileName';
    paths['documents'] = await File(documentsModelPath).exists() ? documentsModelPath : null;
    
    // 2. 외부 저장소 (Android)
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final externalModelPath = '${externalDir.path}/models/$largeModelFileName';
        paths['external'] = await File(externalModelPath).exists() ? externalModelPath : null;
      }
      
      // 3. Download 폴더 (사용자가 직접 넣을 수 있는 곳)
      final downloadPath = '/storage/emulated/0/Download/$largeModelFileName';
      paths['download'] = await File(downloadPath).exists() ? downloadPath : null;
      
      // 4. AiModels 폴더 (사용자 지정 폴더)
      final aiModelsPath = '/storage/emulated/0/AiModels/$largeModelFileName';
      try {
        // 권한 확인 후 접근 시도
        final hasPermission = await requestStoragePermission();
        if (hasPermission) {
          paths['aimodels'] = await File(aiModelsPath).exists() ? aiModelsPath : null;
        } else {
          print('AiModels 폴더 접근 권한 없음');
          paths['aimodels'] = null;
        }
      } catch (e) {
        print('AiModels 폴더 접근 실패: $e');
        paths['aimodels'] = null;
      }
    }
    
    return paths;
  }
  
  /// 사용 가능한 모델 중 최적의 모델을 자동으로 선택합니다.
  /// 
  /// 우선순위:
  /// 1. AiModels 폴더
  /// 2. Download 폴더
  /// 3. Documents 폴더
  /// 4. 외부 저장소
  /// 
  /// Returns:
  ///   - `Future<String>`: 선택된 모델의 전체 경로
  /// 
  /// Throws:
  ///   - `Exception`: 사용 가능한 모델이 없는 경우
  /// 
  /// 사용 예:
  /// ```dart
  /// try {
  ///   final modelPath = await ModelManager.getBestAvailableModel();
  ///   print('선택된 모델: $modelPath');
  /// } catch (e) {
  ///   print('모델을 찾을 수 없습니다: $e');
  /// }
  /// ```
  static Future<String> getBestAvailableModel() async {
    final models = await getAvailableModels();
    
    // 우선순위: AiModels > Download > Documents > External
    if (models['aimodels'] != null) {
      print('큰 모델 사용: AiModels 폴더');
      return models['aimodels']!;
    }
    
    if (models['download'] != null) {
      print('큰 모델 사용: Download 폴더');
      return models['download']!;
    }
    
    if (models['documents'] != null) {
      print('큰 모델 사용: Documents 폴더');
      return models['documents']!;
    }
    
    if (models['external'] != null) {
      print('큰 모델 사용: 외부 저장소');
      return models['external']!;
    }
    
    throw Exception('사용 가능한 모델이 없습니다. 모델 파일을 설치해주세요.');
  }
  
  /// 모델 설치 가이드 메시지
  static String getInstallationGuide() {
    if (Platform.isAndroid) {
      return '''
큰 AI 모델 사용하기:

1. AiModels 폴더에 배치 (권장):
   /storage/emulated/0/AiModels/$largeModelFileName

2. 다운로드 폴더에 배치:
   /storage/emulated/0/Download/$largeModelFileName

3. 앱 전용 폴더에 배치:
   Android/data/com.example.pokifairy/files/models/$largeModelFileName

4. 파일 관리자로 직접 복사하거나
   PC에서 USB로 전송하세요.

      ''';
    } else {
      return '''
큰 AI 모델 사용하기:

1. iTunes 파일 공유로 Documents/models/ 폴더에 배치
2. 파일 앱에서 직접 복사

파일명: $largeModelFileName

      ''';
    }
  }
  
  /// 모델 파일 크기 확인
  static Future<int> getModelFileSize(String path) async {
    if (path.startsWith('assets://')) {
      return 0; // assets 파일 크기는 런타임에 확인 어려움
    }
    
    final file = File(path);
    if (await file.exists()) {
      final stat = await file.stat();
      return stat.size;
    }
    
    return 0;
  }
  
  /// 사용자 친화적인 파일 크기 표시
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
  
  /// 모델 폴더 경로 가져오기
  static Future<String> _getModelsDirectoryPath() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/AiModels';
    } else {
      final documentsDir = await getApplicationDocumentsDirectory();
      return '${documentsDir.path}/AiModels';
    }
  }
  
  /// 모델 폴더 경로 (표시용)
  static String getModelsDirectory() {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/AiModels/';
    } else {
      return 'Documents/AiModels/';
    }
  }
  
  /// 저장소 접근 권한을 확인하고 필요시 요청합니다.
  /// 
  /// Android 버전에 따라 다른 권한을 처리합니다:
  /// - Android 11+ (API 30+): MANAGE_EXTERNAL_STORAGE (모든 파일 접근)
  /// - Android 13+ (API 33+): 세분화된 미디어 권한 (photos, videos, audio)
  /// - Android 10 이하: 기본 STORAGE 권한
  /// 
  /// Returns:
  ///   - `Future<bool>`: 권한 허용 여부
  ///     - `true`: 권한이 허용됨
  ///     - `false`: 권한이 거부됨
  /// 
  /// 동작 방식:
  /// 1. 현재 권한 상태 확인
  /// 2. 권한이 없으면 요청
  /// 3. 영구 거부된 경우 false 반환
  /// 
  /// 사용 예:
  /// ```dart
  /// final hasPermission = await ModelManager.requestStoragePermission();
  /// if (!hasPermission) {
  ///   showDialog(context, '저장소 권한이 필요합니다');
  /// }
  /// ```
  /// 
  /// 주의: iOS에서는 항상 true를 반환합니다.
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;
    
    try {
      // Android 11+ (API 30+)에서는 MANAGE_EXTERNAL_STORAGE 권한이 최우선
      if (await Permission.manageExternalStorage.isGranted) {
        print('MANAGE_EXTERNAL_STORAGE 권한이 이미 허용됨');
        return true;
      }
      
      // Android 13+ (API 33+)에서는 세분화된 미디어 권한도 확인
      if (await Permission.photos.isGranted || 
          await Permission.videos.isGranted || 
          await Permission.audio.isGranted) {
        print('세분화된 미디어 권한이 허용됨');
        return true;
      }
      
      // Android 10 이하에서는 기본 저장소 권한
      if (await Permission.storage.isGranted) {
        print('기본 저장소 권한이 허용됨');
        return true;
      }
      
      print('저장소 권한이 없음. 권한 요청 시작...');
      
      // MANAGE_EXTERNAL_STORAGE 권한 요청 (최우선)
      try {
        print('MANAGE_EXTERNAL_STORAGE 권한 요청 중...');
        final manageStatus = await Permission.manageExternalStorage.request();
        print('MANAGE_EXTERNAL_STORAGE 권한 요청 결과: $manageStatus');
        
        if (manageStatus.isGranted) {
          print('MANAGE_EXTERNAL_STORAGE 권한 허용됨');
          return true;
        } else if (manageStatus.isPermanentlyDenied) {
          print('MANAGE_EXTERNAL_STORAGE 권한이 영구적으로 거부됨. 설정에서 수동 허용 필요');
          return false;
        }
      } catch (e) {
        print('MANAGE_EXTERNAL_STORAGE 권한 요청 실패: $e');
      }
      
      // 세분화된 미디어 권한 요청 (Android 13+)
      try {
        print('세분화된 미디어 권한 요청 중...');
        final photosStatus = await Permission.photos.request();
        final videosStatus = await Permission.videos.request();
        final audioStatus = await Permission.audio.request();
        
        print('미디어 권한 요청 결과 - Photos: $photosStatus, Videos: $videosStatus, Audio: $audioStatus');
        
        if (photosStatus.isGranted || videosStatus.isGranted || audioStatus.isGranted) {
          print('세분화된 미디어 권한 중 하나가 허용됨');
          return true;
        }
      } catch (e) {
        print('세분화된 미디어 권한 요청 실패: $e');
      }
      
      // 기본 저장소 권한 요청 (Android 10 이하)
      try {
        print('기본 저장소 권한 요청 중...');
        final storageStatus = await Permission.storage.request();
        print('기본 저장소 권한 요청 결과: $storageStatus');
        return storageStatus.isGranted;
      } catch (e) {
        print('기본 저장소 권한 요청 실패: $e');
        return false;
      }
      
    } catch (e) {
      print('권한 요청 전체 실패: $e');
      return false;
    }
  }
  
  /// 모델 폴더를 스캔하여 모든 AI 모델 파일을 찾습니다.
  /// 
  /// 이 메서드는 다음 작업을 수행합니다:
  /// 1. 저장소 권한 확인 및 요청
  /// 2. 모델 폴더 존재 확인 (없으면 생성)
  /// 3. `.gguf`, `.onnx`, `.tflite` 확장자를 가진 모든 파일 검색
  /// 4. 각 모델의 메타데이터 수집
  /// 5. 크기 순으로 정렬 (큰 것부터)
  /// 
  /// Returns:
  ///   - `Future<List<ModelInfo>>`: 발견된 모델 정보 리스트
  ///     - 빈 리스트: 권한이 없거나 모델이 없는 경우
  /// 
  /// 사용 예:
  /// ```dart
  /// final models = await ModelManager.scanForModels();
  /// for (final model in models) {
  ///   print('${model.name} - ${model.formattedSize}');
  /// }
  /// ```
  /// 
  /// 주의: 이 메서드는 저장소 권한이 필요합니다.
  static Future<List<ModelInfo>> scanForModels() async {
    // 권한 확인
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      print('저장소 권한이 없습니다');
      return [];
    }
    
    final modelsPath = await _getModelsDirectoryPath();
    final modelsDir = Directory(modelsPath);
    
    print('모델 폴더 스캔: $modelsPath');
    
    if (!await modelsDir.exists()) {
      try {
        await modelsDir.create(recursive: true);
        print('모델 폴더 생성: $modelsPath');
      } catch (e) {
        print('모델 폴더 생성 실패: $e');
        return [];
      }
    }
    
    final models = <ModelInfo>[];
    
    try {
      await for (final entity in modelsDir.list()) {
        if (entity is File) {
          final lowerPath = entity.path.toLowerCase();
          
          // .onnx.data 파일은 스킵 (메인 .onnx 파일만 표시)
          if (lowerPath.endsWith('.onnx.data')) {
            continue;
          }
          
          // 지원하는 모델 형식: GGUF, ONNX, TFLite
          if (lowerPath.endsWith('.gguf') || 
              lowerPath.endsWith('.onnx') || 
              lowerPath.endsWith('.tflite') ||
              lowerPath.endsWith('.lite')) {
            try {
              final stat = await entity.stat();
              final name = entity.path.split('/').last;
              
              // 모델 형식 감지
              String format = 'Unknown';
              if (lowerPath.endsWith('.gguf')) {
                format = 'GGUF';
              } else if (lowerPath.endsWith('.onnx')) {
                format = 'ONNX';
              } else if (lowerPath.endsWith('.tflite') || lowerPath.endsWith('.lite')) {
                format = 'TFLite';
              }
              
              print('모델 파일 발견: $name [$format] (${formatFileSize(stat.size)})');
              
              models.add(ModelInfo(
                name: name,
                path: entity.path,
                size: stat.size,
                formattedSize: formatFileSize(stat.size),
                architecture: guessArchitecture(name),
                quantization: guessQuantization(name),
              ));
            } catch (e) {
              print('모델 파일 정보 읽기 실패: ${entity.path} - $e');
            }
          }
        }
      }
    } catch (e) {
      print('모델 폴더 스캔 실패: $e');
    }
    
    // 크기 순으로 정렬 (큰 것부터)
    models.sort((a, b) => b.size.compareTo(a.size));
    
    print('총 ${models.length}개 모델 발견');
    return models;
  }
  
  /// 파일명에서 아키텍처 추측
  static String? guessArchitecture(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.contains('gemma')) return 'Gemma';
    if (lower.contains('llama')) return 'Llama';
    if (lower.contains('qwen')) return 'Qwen';
    if (lower.contains('mistral')) return 'Mistral';
    if (lower.contains('phi')) return 'Phi';
    return null;
  }
  
  /// 파일명에서 양자화 방식 추측
  static String? guessQuantization(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.contains('q4_k_m')) return 'Q4_K_M';
    if (lower.contains('q4_0')) return 'Q4_0';
    if (lower.contains('q5_k_m')) return 'Q5_K_M';
    if (lower.contains('q8_0')) return 'Q8_0';
    if (lower.contains('f16')) return 'F16';
    if (lower.contains('f32')) return 'F32';
    return null;
  }
  
  /// 현재 선택된 모델 가져오기
  static Future<ModelInfo?> getCurrentModel() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPath = prefs.getString(_currentModelKey);
    
    if (currentPath == null) return null;
    
    // 파일이 존재하는지 확인
    final file = File(currentPath);
    if (!await file.exists()) {
      // 파일이 없으면 설정 제거
      await prefs.remove(_currentModelKey);
      return null;
    }
    
    try {
      final stat = await file.stat();
      final name = currentPath.split('/').last;
      
      return ModelInfo(
        name: name,
        path: currentPath,
        size: stat.size,
        formattedSize: formatFileSize(stat.size),
        architecture: guessArchitecture(name),
        quantization: guessQuantization(name),
      );
    } catch (e) {
      print('현재 모델 정보 읽기 실패: $currentPath - $e');
      return null;
    }
  }
  
  /// 현재 모델 설정
  static Future<void> setCurrentModel(String modelPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentModelKey, modelPath);
  }
  
  /// 현재 모델 경로 가져오기
  static Future<String?> getCurrentModelPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentModelKey);
  }
  
  /// AiModels 폴더 접근 테스트
  static Future<Map<String, dynamic>> testAiModelsAccess() async {
    final result = <String, dynamic>{
      'hasPermission': false,
      'canAccess': false,
      'folderExists': false,
      'files': <String>[],
      'error': null,
      'permissionStatus': <String, dynamic>{},
    };
    
    try {
      // 상세 권한 상태 확인
      final permissionStatus = <String, dynamic>{
        'manageExternalStorage': await Permission.manageExternalStorage.status,
        'storage': await Permission.storage.status,
        'photos': await Permission.photos.status,
        'videos': await Permission.videos.status,
        'audio': await Permission.audio.status,
      };
      result['permissionStatus'] = permissionStatus;
      
      // 권한 확인
      result['hasPermission'] = await requestStoragePermission();
      
      if (!result['hasPermission']) {
        result['error'] = '저장소 권한이 없습니다. 설정에서 "모든 파일 접근" 권한을 허용해주세요.';
        return result;
      }
      
      // 폴더 접근 테스트
      const aiModelsPath = '/storage/emulated/0/AiModels';
      final aiModelsDir = Directory(aiModelsPath);
      
      result['folderExists'] = await aiModelsDir.exists();
      
      if (result['folderExists']) {
        try {
          // 폴더 내용 읽기
          final files = <String>[];
          await for (final entity in aiModelsDir.list()) {
            if (entity is File) {
              files.add(entity.path.split('/').last);
            }
          }
          result['files'] = files;
          result['canAccess'] = true;
        } catch (e) {
          result['error'] = '폴더 내용 읽기 실패: $e';
        }
      } else {
        result['error'] = 'AiModels 폴더가 존재하지 않습니다';
      }
      
    } catch (e) {
      result['error'] = '접근 테스트 실패: $e';
    }
    
    return result;
  }
  
  /// 권한 설정 가이드 메시지
  static String getPermissionGuide() {
    return '''
📱 Android 저장소 권한 설정 가이드

AiModels 폴더에 접근하려면 다음 권한이 필요합니다:

🔧 설정 방법:
1. Android 설정 → 앱 → PokiFairy
2. 권한 → 저장소 → "모든 파일 접근" 허용
3. 또는 "특별 앱 액세스" → "모든 파일 액세스" 허용

⚠️ 중요:
• Android 11+ (API 30+)에서는 "모든 파일 접근" 권한이 필요합니다
• 이 권한은 보안상 수동으로 설정해야 합니다
• 앱에서 자동으로 요청할 수 없습니다

📁 대안 경로:
권한 설정이 어려운 경우 다음 경로를 사용하세요:
• /storage/emulated/0/Download/
• 앱 전용 Documents 폴더
    ''';
  }
}
