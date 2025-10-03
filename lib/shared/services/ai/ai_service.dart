import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'gguf_loader.dart';
import 'model_manager.dart';

/// On-Device AI 서비스
/// 
/// GGUF 형식의 AI 모델을 사용하여 디바이스에서 직접 AI 추론을 수행합니다.
/// llama.cpp 엔진을 FFI를 통해 호출하여 프라이버시를 보장하고 오프라인에서도 동작합니다.
/// 
/// 주요 기능:
/// - AI 모델 초기화 및 관리
/// - 스트리밍 방식의 AI 응답 생성
/// - 배터리 최적화 및 메모리 관리
/// - 백그라운드 상태 처리
/// - 디버그 로깅
/// 
/// 사용 예:
/// ```dart
/// final aiService = AIService.instance;
/// await aiService.initialize();
/// 
/// await for (final chunk in aiService.generateResponseStream('안녕하세요')) {
///   print(chunk);
/// }
/// ```
/// 
/// 싱글톤 패턴을 사용하여 앱 전체에서 하나의 인스턴스만 유지합니다.
class AIService {
  static AIService? _instance;
  
  /// AIService의 싱글톤 인스턴스를 반환합니다.
  static AIService get instance => _instance ??= AIService._();
  
  /// Private 생성자 - 싱글톤 패턴 구현
  AIService._();
  
  bool _isInitialized = false;
  String? _modelPath;
  InferenceEngine? _inferenceEngine;
  Map<String, dynamic>? _modelInfo;
  final List<String> _debugLogs = [];
  DateTime? _initializationTime;
  bool _isBackgrounded = false;
  bool _batteryOptimizationEnabled = true;
  
  /// AI 서비스를 초기화합니다.
  /// 
  /// 이 메서드는 다음 작업을 수행합니다:
  /// 1. 사용 가능한 AI 모델 검색
  /// 2. 모델 파일 유효성 검증
  /// 3. GGUF 추론 엔진 로드
  /// 4. 초기화 시간 기록
  /// 
  /// Returns:
  ///   - `true`: 초기화 성공
  ///   - `false`: 초기화 실패
  /// 
  /// Throws:
  ///   - `Exception`: 모델 파일이 없거나 유효하지 않은 경우
  /// 
  /// 주의: 이미 초기화된 경우 즉시 `true`를 반환합니다.
  /// 
  /// 사용 예:
  /// ```dart
  /// final success = await aiService.initialize();
  /// if (success) {
  ///   print('AI 서비스 준비 완료');
  /// }
  /// ```
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _addDebugLog('AI 서비스 초기화 시작');
      final startTime = DateTime.now();
      
      // 모바일 환경에서만 동작
      await _initializeForMobile();
      
      _initializationTime = DateTime.now();
      final duration = _initializationTime!.difference(startTime);
      _addDebugLog('AI 서비스 초기화 완료 (소요 시간: ${duration.inMilliseconds}ms)');
      
      _isInitialized = true;
      return true;
    } catch (e) {
      _addDebugLog('AI 서비스 초기화 실패: $e');
      print('AI 서비스 초기화 실패: $e');
      return false;
    }
  }
  
  /// 모바일 환경에서 AI 모델을 초기화합니다.
  /// 
  /// 이 메서드는 다음 작업을 수행합니다:
  /// 1. 저장된 모델 경로 확인 또는 최적 모델 자동 선택
  /// 2. GGUF 모델 파일 유효성 검증
  /// 3. 추론 엔진 로드 및 초기화
  /// 
  /// Throws:
  ///   - `Exception`: 모델 파일 검증 실패 시
  Future<void> _initializeForMobile() async {
    // 현재 선택된 모델 또는 최적의 모델 선택
    _addDebugLog('모델 경로 검색 중...');
    final currentModelPath = await ModelManager.getCurrentModelPath();
    if (currentModelPath != null && await File(currentModelPath).exists()) {
      _modelPath = currentModelPath;
      _addDebugLog('저장된 모델 경로 사용: $_modelPath');
    } else {
      _modelPath = await ModelManager.getBestAvailableModel();
      _addDebugLog('최적 모델 자동 선택: $_modelPath');
    }
    
    print('선택된 모델: $_modelPath');
    
    // 모델 정보 확인
    _addDebugLog('모델 정보 로드 중...');
    _modelInfo = await GGUFLoader.getModelInfo(_modelPath!);
    
    print('모델 정보: $_modelInfo');
    
    if (_modelInfo!['isValid']) {
      final fileSize = await ModelManager.getModelFileSize(_modelPath!);
      final formattedSize = ModelManager.formatFileSize(fileSize);
      _addDebugLog('유효한 GGUF 모델 파일 발견: $formattedSize');
      print('유효한 GGUF 모델 파일 발견: $formattedSize');
      
      // 실제 GGUF 엔진 로드
      _addDebugLog('GGUF 추론 엔진 로드 중...');
      _inferenceEngine = GGUFInferenceEngine();
      await _inferenceEngine!.loadModel(_modelPath!);
      _addDebugLog('GGUF 추론 엔진 로드 성공');
      print('모바일 환경에서 실제 GGUF 엔진 로드 성공');
    } else {
      final error = '모델 파일 검증 실패: ${_modelInfo!['error']}';
      _addDebugLog(error);
      throw Exception(error);
    }
    
    _addDebugLog('모바일 환경 초기화 완료');
    print('모바일 환경 초기화 완료');
  }
  
  /// 사용 가능한 모델들 정보 조회
  Future<Map<String, dynamic>> getAvailableModelsInfo() async {
    final models = await ModelManager.getAvailableModels();
    final result = <String, dynamic>{};
    
    for (final entry in models.entries) {
      if (entry.value != null) {
        final size = await ModelManager.getModelFileSize(entry.value!);
        result[entry.key] = {
          'path': entry.value,
          'size': size,
          'formattedSize': ModelManager.formatFileSize(size),
          'exists': true,
        };
      } else {
        result[entry.key] = {
          'path': null,
          'size': 0,
          'formattedSize': '0B',
          'exists': false,
        };
      }
    }
    
    return result;
  }
  
  /// 모델 설치 가이드 가져오기
  String getModelInstallationGuide() {
    return ModelManager.getInstallationGuide();
  }
  
  /// AI 모델에게 질문하고 스트리밍 방식으로 응답을 받습니다.
  /// 
  /// 이 메서드는 사용자 친화적인 AI 응답을 생성합니다:
  /// - 초등학생도 이해하기 쉬운 언어로 변환
  /// - 실시간 스트리밍으로 응답 표시
  /// - 배터리 최적화 모드 지원
  /// - 백그라운드 상태에서 자동 중단
  /// 
  /// Parameters:
  ///   - `prompt`: 사용자의 질문 또는 입력 텍스트
  /// 
  /// Returns:
  ///   - `Stream<String>`: AI 응답 텍스트의 스트림 (토큰 단위)
  /// 
  /// 동작 방식:
  /// 1. 서비스가 초기화되지 않은 경우 자동 초기화
  /// 2. 사용자 프롬프트를 아동 친화적으로 변환
  /// 3. 배터리 최적화 모드에 따라 토큰 수 조정
  /// 4. 스트리밍 방식으로 응답 생성
  /// 5. 백그라운드 전환 시 즉시 중단
  /// 
  /// 사용 예:
  /// ```dart
  /// await for (final chunk in aiService.generateResponseStream('안녕하세요')) {
  ///   print(chunk); // 실시간으로 응답 출력
  /// }
  /// ```
  /// 
  /// 주의:
  /// - 앱이 백그라운드로 전환되면 생성이 중단됩니다
  /// - 에러 발생 시 사용자 친화적인 메시지를 반환합니다
  Stream<String> generateResponseStream(String prompt) async* {
    if (!_isInitialized) {
      await initialize();
    }
    
    // 백그라운드 상태에서는 AI 작업 중단
    if (_isBackgrounded) {
      _addDebugLog('백그라운드 상태에서 AI 작업 중단됨');
      yield '앱이 백그라운드 상태입니다. 다시 시도해주세요.';
      return;
    }
    
    try {
      if (_inferenceEngine != null) {
        // 초등학생에 맞는 프롬프트 수정
        final childFriendlyPrompt = _makeChildFriendlyPrompt(prompt);
        
        // 배터리 최적화 모드에 따라 토큰 한도 조정
        final maxTokens = _batteryOptimizationEnabled ? 512 : 1024;
        
        // 스트리밍 응답 생성
        await for (final chunk in _inferenceEngine!.generateStream(
          childFriendlyPrompt, 
          maxTokens: maxTokens,
        )) {
          // 백그라운드로 전환되면 즉시 중단
          if (_isBackgrounded) {
            _addDebugLog('AI 생성 중 백그라운드 전환으로 중단됨');
            break;
          }
          yield chunk;
        }
      } else {
        throw Exception('추론 엔진이 초기화되지 않았습니다');
      }
    } catch (e) {
      print('AI 응답 생성 실패: $e');
      yield '미안해요, 지금 대답하기 어렵네요... 😅\n다시 한번 말해주실래요?';
    }
  }

  /// AI 모델에게 질문하고 전체 응답을 한 번에 받습니다.
  /// 
  /// 스트리밍이 아닌 일반 방식으로 AI 응답을 생성합니다.
  /// 전체 응답이 생성될 때까지 대기합니다.
  /// 
  /// Parameters:
  ///   - `prompt`: 사용자의 질문 또는 입력 텍스트
  /// 
  /// Returns:
  ///   - `Future<String>`: 완성된 AI 응답 텍스트
  /// 
  /// Throws:
  ///   - `Exception`: 추론 엔진이 초기화되지 않았거나 응답 생성 실패 시
  /// 
  /// 사용 예:
  /// ```dart
  /// final response = await aiService.generateResponse('안녕하세요');
  /// print(response); // 완성된 응답 출력
  /// ```
  /// 
  /// 주의: 실시간 피드백이 필요한 경우 `generateResponseStream`을 사용하세요.
  Future<String> generateResponse(String prompt) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      if (_inferenceEngine != null) {
        return await _inferenceEngine!.generate(prompt);
      } else {
        throw Exception('추론 엔진이 초기화되지 않았습니다');
      }
    } catch (e) {
      print('AI 응답 생성 실패: $e');
      rethrow;
    }
  }

  /// 사용자 프롬프트를 아동 친화적인 형식으로 변환합니다.
  /// 
  /// 이 메서드는 AI가 초등학생에게 적합한 방식으로 응답하도록
  /// 시스템 프롬프트를 추가합니다:
  /// - 친근하고 따뜻한 말투
  /// - 쉽고 간단한 설명
  /// - 적절한 이모지 사용
  /// - 코드 블록이나 기술 용어 제한
  /// 
  /// Parameters:
  ///   - `userPrompt`: 원본 사용자 입력
  /// 
  /// Returns:
  ///   - `String`: 시스템 프롬프트가 추가된 전체 프롬프트
  String _makeChildFriendlyPrompt(String userPrompt) {
    return '''당신은 초등학생 친구 '지키미'입니다.

절대 금지:
- 코드 블록(```) 사용 금지
- "질문:", "답변:", "지키미:" 라벨 금지
- 자문자답 금지
- HTML 태그 금지
- 반복 패턴 금지

답변 스타일:
- 친근하고 따뜻하게 😊
- 쉽고 간단하게
- 이모지 적당히 사용 🐻
- 예시로 설명하기

질문: $userPrompt

지키미:''';
  }
  
  /// 모델 정보 조회
  Map<String, dynamic>? get modelInfo => _modelInfo;
  
  /// 초기화 시간 조회
  DateTime? get initializationTime => _initializationTime;
  
  /// 초기화 상태 조회
  bool get isInitialized => _isInitialized;
  
  /// 현재 모델 경로 조회
  String? get currentModelPath => _modelPath;
  
  /// 디버그 로그 조회
  List<String> get debugLogs => List.unmodifiable(_debugLogs);
  
  /// 추론 엔진 상태 조회
  Map<String, dynamic>? get engineStatus {
    if (_inferenceEngine is GGUFInferenceEngine) {
      return (_inferenceEngine as GGUFInferenceEngine).status;
    }
    return null;
  }
  
  /// 전체 디버그 정보 조회
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'modelPath': _modelPath,
      'modelInfo': _modelInfo,
      'initializationTime': _initializationTime?.toIso8601String(),
      'engineStatus': engineStatus,
      'debugLogs': _debugLogs,
      'logCount': _debugLogs.length,
    };
  }
  
  /// 디버그 로그 추가
  void _addDebugLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _debugLogs.add('[$timestamp] $message');
    
    // 로그가 너무 많아지면 오래된 것 제거 (최대 100개)
    if (_debugLogs.length > 100) {
      _debugLogs.removeAt(0);
    }
  }
  
  /// 디버그 로그 초기화
  void clearDebugLogs() {
    _debugLogs.clear();
    _addDebugLog('디버그 로그 초기화됨');
  }
  
  /// AI 서비스 재초기화 (모델 변경 시 사용)
  Future<bool> reinitialize() async {
    _addDebugLog('AI 서비스 재초기화 시작');
    dispose();
    return await initialize();
  }
  
  /// 백그라운드 상태 설정
  /// 
  /// 앱이 백그라운드로 전환될 때 호출하여 AI 작업을 중단합니다.
  void setBackgroundState(bool isBackgrounded) {
    _isBackgrounded = isBackgrounded;
    _addDebugLog('백그라운드 상태 변경: $isBackgrounded');
    
    if (isBackgrounded) {
      _addDebugLog('백그라운드 전환: AI 작업 중단');
    }
  }
  
  /// 배터리 최적화 모드 설정
  /// 
  /// 배터리 최적화가 활성화되면 더 적은 토큰으로 응답을 생성합니다.
  void setBatteryOptimization(bool enabled) {
    _batteryOptimizationEnabled = enabled;
    _addDebugLog('배터리 최적화 모드: $enabled');
  }
  
  /// 배터리 최적화 상태 조회
  bool get isBatteryOptimizationEnabled => _batteryOptimizationEnabled;
  
  /// 백그라운드 상태 조회
  bool get isBackgrounded => _isBackgrounded;
  
  /// 메모리 부족 시 모델 언로드
  /// 
  /// 메모리 압박 상황에서 AI 모델을 메모리에서 해제합니다.
  /// 다음 사용 시 다시 로드됩니다.
  void unloadModel() {
    if (!_isInitialized) return;
    
    _addDebugLog('메모리 부족으로 인한 모델 언로드 시작');
    _inferenceEngine?.dispose();
    _inferenceEngine = null;
    _isInitialized = false;
    _addDebugLog('모델 언로드 완료 (경로는 유지: $_modelPath)');
  }
  
  /// 메모리 상태 확인
  /// 
  /// 현재 메모리 사용 상태를 반환합니다.
  /// - 'modelLoaded': 모델이 메모리에 로드되어 있는지
  /// - 'canUnload': 언로드 가능한지
  Map<String, dynamic> getMemoryStatus() {
    return {
      'modelLoaded': _isInitialized && _inferenceEngine != null,
      'canUnload': _isInitialized,
      'modelPath': _modelPath,
      'initializationTime': _initializationTime?.toIso8601String(),
    };
  }
  
  /// 리소스 정리
  void dispose() {
    _addDebugLog('AI 서비스 리소스 정리 시작');
    _inferenceEngine?.dispose();
    _isInitialized = false;
    _modelPath = null;
    _inferenceEngine = null;
    _modelInfo = null;
    _initializationTime = null;
    _addDebugLog('AI 서비스 리소스 정리 완료');
  }
}
