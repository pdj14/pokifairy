import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'gguf_loader.dart';

/// TensorFlow Lite 추론 엔진
/// 
/// TFLite를 사용하여 TensorFlow Lite 형식의 AI 모델을 실행합니다.
/// - 모바일 최적화
/// - GPU 가속 지원
/// - 경량화된 모델
class TFLiteInferenceEngine implements InferenceEngine {
  Interpreter? _interpreter;
  bool _isLoaded = false;
  String? _modelPath;
  
  // 모델 입출력 정보
  List<int>? _inputShape;
  List<int>? _outputShape;
  
  // 토크나이저 관련 (간단한 구현)
  final Map<String, int> _vocab = {};
  final Map<int, String> _reverseVocab = {};
  int _vocabSize = 32000;
  
  @override
  Future<void> loadModel(String modelPath) async {
    try {
      print('TFLite 모델 로드 시작: $modelPath');
      
      // 파일 존재 확인
      final file = File(modelPath);
      if (!await file.exists()) {
        throw Exception('모델 파일이 존재하지 않습니다: $modelPath');
      }
      
      // TFLite 인터프리터 옵션 설정
      final options = InterpreterOptions()
        ..threads = 4;
      
      // Android에서 NNAPI 사용 시도
      if (Platform.isAndroid) {
        try {
          options.useNnApiForAndroid = true;
          print('Android NNAPI 활성화');
        } catch (e) {
          print('NNAPI 활성화 실패: $e');
        }
      }
      
      // GPU 델리게이트 시도 (가능한 경우)
      try {
        final gpuDelegate = GpuDelegateV2(
          options: GpuDelegateOptionsV2(
            isPrecisionLossAllowed: false,
          ),
        );
        options.addDelegate(gpuDelegate);
        print('GPU 델리게이트 추가 성공');
      } catch (e) {
        print('GPU 델리게이트 추가 실패 (CPU 사용): $e');
      }
      
      // 모델 로드
      _interpreter = await Interpreter.fromFile(file, options: options);
      
      // 입출력 shape 확인
      _inputShape = _interpreter!.getInputTensor(0).shape;
      _outputShape = _interpreter!.getOutputTensor(0).shape;
      
      _modelPath = modelPath;
      _isLoaded = true;
      
      // 간단한 vocab 초기화
      _initializeSimpleVocab();
      
      print('TFLite 모델 로드 완료: $modelPath');
      print('입력 shape: $_inputShape');
      print('출력 shape: $_outputShape');
    } catch (e) {
      print('TFLite 모델 로드 실패: $e');
      rethrow;
    }
  }
  
  /// 간단한 vocab 초기화
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
  
  /// 간단한 토크나이저
  List<int> _tokenize(String text) {
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
    if (!_isLoaded || _interpreter == null) {
      throw Exception('모델이 로드되지 않았습니다');
    }
    
    try {
      // 토큰화
      final inputTokens = _tokenize(prompt);
      
      // 입력 shape에 맞게 패딩 또는 자르기
      final maxLength = _inputShape![1];
      final paddedTokens = List<int>.filled(maxLength, 0);
      for (var i = 0; i < inputTokens.length && i < maxLength; i++) {
        paddedTokens[i] = inputTokens[i];
      }
      
      // TFLite 입력 준비 (2D: [batch_size, sequence_length])
      final input = [paddedTokens.map((e) => e.toDouble()).toList()];
      
      // 출력 버퍼 준비
      final outputLength = _outputShape![1];
      final output = List.generate(
        1,
        (_) => List<double>.filled(outputLength, 0),
      );
      
      // 추론 실행
      _interpreter!.run(input, output);
      
      // 출력을 토큰으로 변환
      final outputTokens = output[0]
          .take(maxTokens)
          .map((e) => e.toInt())
          .toList();
      
      // 디토크나이징
      final result = _detokenize(outputTokens);
      
      return result;
    } catch (e) {
      print('TFLite 추론 실패: $e');
      rethrow;
    }
  }
  
  @override
  Stream<String> generateStream(String prompt, {int maxTokens = 1024}) async* {
    if (!_isLoaded || _interpreter == null) {
      throw Exception('모델이 로드되지 않았습니다');
    }
    
    try {
      // TFLite는 기본적으로 스트리밍을 지원하지 않으므로
      // 전체 생성 후 청크로 나눠서 전송
      final result = await generate(prompt, maxTokens: maxTokens);
      
      // 단어 단위로 스트리밍 시뮬레이션
      final words = result.split(' ');
      for (var i = 0; i < words.length; i++) {
        yield words[i] + (i < words.length - 1 ? ' ' : '');
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      print('TFLite 스트리밍 생성 실패: $e');
      yield '미안해요, 지금 대답하기 어렵네요... 😅\n다시 한번 말해주실래요?';
    }
  }
  
  @override
  void dispose() {
    if (_isLoaded) {
      _interpreter?.close();
      _interpreter = null;
      _isLoaded = false;
      _modelPath = null;
      print('TFLite 추론 엔진 정리 완료');
    }
  }
  
  /// 현재 상태 정보
  Map<String, dynamic> get status => {
    'isLoaded': _isLoaded,
    'modelPath': _modelPath,
    'platform': 'TensorFlow Lite',
    'inputShape': _inputShape,
    'outputShape': _outputShape,
  };
}
