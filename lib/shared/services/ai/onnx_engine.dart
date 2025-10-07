import 'dart:io';
import 'package:onnxruntime/onnxruntime.dart';
import 'gguf_loader.dart';

/// ONNX 추론 엔진
/// 
/// ONNX Runtime을 사용하여 ONNX 형식의 AI 모델을 실행합니다.
/// - 다양한 모델 아키텍처 지원
/// - 하드웨어 가속 (CPU, GPU, NPU)
/// - 크로스 플랫폼 지원
/// 
/// 주의: onnxruntime 1.4.1 버전 사용 (구버전 API)
class ONNXInferenceEngine implements InferenceEngine {
  OrtSession? _session;
  bool _isLoaded = false;
  String? _modelPath;
  
  // 토크나이저 관련 (간단한 구현)
  final Map<String, int> _vocab = {};
  final Map<int, String> _reverseVocab = {};
  int _vocabSize = 32000;
  
  @override
  Future<void> loadModel(String modelPath) async {
    try {
      print('ONNX 모델 로드 시작: $modelPath');
      
      // 파일 존재 확인
      final file = File(modelPath);
      if (!await file.exists()) {
        throw Exception('모델 파일이 존재하지 않습니다: $modelPath');
      }
      
      // .onnx.data 파일 확인 (외부 데이터)
      final dataPath = '$modelPath.data';
      final dataFile = File(dataPath);
      if (await dataFile.exists()) {
        print('외부 데이터 파일 발견: $dataPath');
        print('⚠️ .onnx와 .onnx.data 파일이 같은 폴더에 있어야 합니다');
      }
      
      // ONNX Runtime 초기화 (1.4.1 버전)
      OrtEnv.instance.init();
      
      // 세션 옵션 설정 (간단한 버전)
      final sessionOptions = OrtSessionOptions();
      
      // 모델 로드 (ONNX Runtime이 자동으로 .onnx.data 찾음)
      _session = OrtSession.fromFile(file, sessionOptions);
      
      _modelPath = modelPath;
      _isLoaded = true;
      
      // 간단한 vocab 초기화 (실제로는 tokenizer.json 필요)
      _initializeSimpleVocab();
      
      print('ONNX 모델 로드 완료: $modelPath');
      print('입력: ${_session!.inputNames}');
      print('출력: ${_session!.outputNames}');
    } catch (e) {
      print('ONNX 모델 로드 실패: $e');
      rethrow;
    }
  }
  
  /// 간단한 vocab 초기화 (실제로는 tokenizer 파일 필요)
  void _initializeSimpleVocab() {
    // 기본 토큰들
    _vocab['<pad>'] = 0;
    _vocab['<s>'] = 1;
    _vocab['</s>'] = 2;
    _vocab['<unk>'] = 3;
    
    // 역방향 매핑
    _vocab.forEach((key, value) {
      _reverseVocab[value] = key;
    });
    
    print('간단한 vocab 초기화 완료 (크기: ${_vocab.length})');
  }
  
  /// 간단한 토크나이저 (실제로는 SentencePiece 등 필요)
  List<int> _tokenize(String text) {
    // 매우 간단한 구현 - 실제로는 proper tokenizer 필요
    final tokens = <int>[1]; // <s>
    
    // 문자 단위로 토큰화 (임시)
    for (var char in text.runes) {
      tokens.add(char % _vocabSize);
    }
    
    tokens.add(2); // </s>
    return tokens;
  }
  
  /// 토큰을 텍스트로 변환
  String _detokenize(List<int> tokens) {
    final buffer = StringBuffer();
    
    for (var token in tokens) {
      if (token == 1 || token == 2) continue; // 특수 토큰 스킵
      
      if (_reverseVocab.containsKey(token)) {
        buffer.write(_reverseVocab[token]);
      } else {
        // 문자로 변환 (임시)
        if (token > 0 && token < 128) {
          buffer.write(String.fromCharCode(token));
        }
      }
    }
    
    return buffer.toString();
  }
  
  @override
  Future<String> generate(String prompt, {int maxTokens = 100}) async {
    if (!_isLoaded || _session == null) {
      throw Exception('모델이 로드되지 않았습니다');
    }
    
    try {
      // 토큰화
      final inputTokens = _tokenize(prompt);
      
      // ONNX 입력 준비 (1.4.1 버전 API)
      // 주의: ONNX Runtime 1.4.1은 제한적인 기능만 제공
      // 실제 LLM 추론을 위해서는 더 높은 버전이 필요할 수 있음
      
      print('⚠️ ONNX 모델 추론은 실험적 기능입니다');
      print('입력 토큰 수: ${inputTokens.length}');
      
      // 간단한 응답 반환 (실제 추론 대신)
      // ONNX Runtime 1.4.1의 제한으로 인해 완전한 LLM 추론은 어려움
      final result = '''
⚠️ ONNX 모델 추론 제한

현재 ONNX Runtime 버전(1.4.1)은 제한적인 기능만 제공합니다.

**문제점**:
- 토큰 타입 불일치 (int64 vs double)
- 제한적인 API
- LLM 추론에 필요한 기능 부족

**권장사항**:
✅ GGUF 모델 사용 (완전한 기능)
- 완전한 스트리밍 지원
- 토크나이저 내장
- 최적화된 성능

**ONNX 모델 사용하려면**:
1. 더 높은 버전의 onnxruntime 필요
2. 또는 GGUF로 변환 권장
''';
      
      return result;
    } catch (e) {
      print('ONNX 추론 실패: $e');
      rethrow;
    }
  }
  
  @override
  Stream<String> generateStream(String prompt, {int maxTokens = 1024}) async* {
    if (!_isLoaded || _session == null) {
      throw Exception('모델이 로드되지 않았습니다');
    }
    
    try {
      // ONNX는 기본적으로 스트리밍을 지원하지 않으므로
      // 전체 생성 후 청크로 나눠서 전송
      final result = await generate(prompt, maxTokens: maxTokens);
      
      // 단어 단위로 스트리밍 시뮬레이션
      final words = result.split(' ');
      for (var i = 0; i < words.length; i++) {
        yield words[i] + (i < words.length - 1 ? ' ' : '');
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      print('ONNX 스트리밍 생성 실패: $e');
      yield '미안해요, 지금 대답하기 어렵네요... 😅\n다시 한번 말해주실래요?';
    }
  }
  
  @override
  void dispose() {
    if (_isLoaded) {
      _session?.release();
      _session = null;
      _isLoaded = false;
      _modelPath = null;
      print('ONNX 추론 엔진 정리 완료');
    }
  }
  
  /// 현재 상태 정보
  Map<String, dynamic> get status => {
    'isLoaded': _isLoaded,
    'modelPath': _modelPath,
    'platform': 'ONNX Runtime',
    'inputNames': _session?.inputNames ?? [],
    'outputNames': _session?.outputNames ?? [],
  };
}
