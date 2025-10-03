import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'native_bindings.dart';

/// GGUF 모델 로더 (향후 실제 구현용)
class GGUFLoader {
  
  /// GGUF 파일 헤더 정보
  static Future<Map<String, dynamic>> getModelInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('파일이 존재하지 않습니다: $filePath');
      }
      
      // 파일 크기가 크므로 헤더만 읽기 (처음 1KB)
      final bytes = await file.openRead(0, 1024).expand((chunk) => chunk).toList();
      final uint8List = Uint8List.fromList(bytes);
      
      final result = _validateGGUFFile(uint8List);
      
      // 실제 파일 크기 추가
      final stat = await file.stat();
      result['fileSize'] = stat.size;
      
      return result;
    } catch (e) {
      return {
        'fileSize': 0,
        'isValid': false,
        'error': e.toString(),
        'platform': 'mobile',
      };
    }
  }
  
  /// GGUF 파일 유효성 검증
  static Map<String, dynamic> _validateGGUFFile(Uint8List bytes) {
    // GGUF 매직 넘버 확인 (0x46554747 = "GGUF")
    if (bytes.length < 4) {
      throw Exception('파일이 너무 작습니다');
    }
    
    final magic = ByteData.sublistView(bytes, 0, 4).getUint32(0, Endian.little);
    if (magic != 0x46554747) {
      throw Exception('유효하지 않은 GGUF 파일입니다');
    }
    
    return {
      'fileSize': bytes.length,
      'isValid': true,
      'magic': magic.toRadixString(16),
      'platform': 'mobile',
    };
  }
  
  /// 모델 메타데이터 파싱 (향후 구현)
  static Future<Map<String, dynamic>> parseMetadata(Uint8List bytes) async {
    // GGUF 파일 구조:
    // - Magic number (4 bytes): "GGUF"
    // - Version (4 bytes)
    // - Tensor count (8 bytes)
    // - Metadata KV count (8 bytes)
    // - Metadata KV pairs
    // - Tensor info
    // - Padding
    // - Tensor data
    
    return {
      'version': 'unknown',
      'tensorCount': 0,
      'metadataCount': 0,
      'architecture': 'gemma',
      'parameters': '270M',
      'quantization': 'Q4_K_M',
    };
  }
}

/// 추론 엔진 인터페이스 (향후 구현용)
abstract class InferenceEngine {
  Future<void> loadModel(String modelPath);
  Future<String> generate(String prompt, {int maxTokens = 100});
  Stream<String> generateStream(String prompt, {int maxTokens = 100});
  void dispose();
}



/// 실제 GGUF 추론 엔진 (FFI 기반)
class GGUFInferenceEngine implements InferenceEngine {
  final NativeBindings _bindings = NativeBindings.instance;
  bool _isLoaded = false;
  String? _modelPath;
  
  @override
  Future<void> loadModel(String modelPath) async {
    try {
      // FFI 바인딩 초기화
      final ffiInitialized = await _bindings.initialize();
      if (!ffiInitialized) {
        throw Exception('FFI 바인딩 초기화 실패');
      }
      
      // llama.cpp 백엔드 초기화
      final llamaInitialized = await _bindings.initializeLlama();
      if (!llamaInitialized) {
        throw Exception('llama.cpp 백엔드 초기화 실패');
      }
      
      // 모델 파일 로드
      final modelLoaded = await _bindings.loadModel(modelPath);
      if (!modelLoaded) {
        throw Exception('모델 파일 로드 실패: $modelPath');
      }
      
      _modelPath = modelPath;
      _isLoaded = true;
      
      print('GGUF 모델 로드 완료: $modelPath');
    } catch (e) {
      print('GGUF 모델 로드 실패: $e');
      rethrow;
    }
  }
  
  @override
  Future<String> generate(String prompt, {int maxTokens = 100}) async {
    if (!_isLoaded) {
      throw Exception('모델이 로드되지 않았습니다');
    }
    
    try {
      // FFI를 통해 실제 텍스트 생성
      final result = await _bindings.generateText(prompt, maxTokens: maxTokens);
      return result;
    } catch (e) {
      print('텍스트 생성 실패: $e');
      rethrow;
    }
  }

  @override
  Stream<String> generateStream(String prompt, {int maxTokens = 1024}) async* {
    if (!_isLoaded) {
      throw Exception('모델이 로드되지 않았습니다');
    }
    
    try {
      // FFI를 통해 스트리밍 텍스트 생성 (자동 이어쓰기 활성화)
      await for (final chunk in _bindings.generateTextStream(prompt, 
        maxTokens: maxTokens, 
        autoContinue: true, 
        maxTotalTokens: 4096,
        respectShortAnswers: false)) {
        yield chunk;
      }
    } catch (e) {
      print('스트리밍 텍스트 생성 실패: $e');
      yield '미안해요, 지금 대답하기 어렵네요... 😅\n다시 한번 말해주실래요?';
    }
  }
  

  
  /// 모델 정보 조회
  Future<String> getModelInfo() async {
    if (!_isLoaded) {
      return '모델이 로드되지 않았습니다';
    }
    
    try {
      return await _bindings.getModelInfo();
    } catch (e) {
      return '모델 정보 조회 실패: $e';
    }
  }
  
  @override
  void dispose() {
    if (_isLoaded) {
      _bindings.dispose();
      _isLoaded = false;
      _modelPath = null;
      print('GGUF 추론 엔진 정리 완료');
    }
  }
  
  /// 현재 상태 정보
  Map<String, dynamic> get status => {
    'isLoaded': _isLoaded,
    'modelPath': _modelPath,
    'platform': _bindings.platformInfo,
    'ffiSupported': _bindings.isFFISupported,
  };
}
