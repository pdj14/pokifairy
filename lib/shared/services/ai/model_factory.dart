import 'dart:io';
import 'dart:typed_data';
import 'gguf_loader.dart';
import 'onnx_engine.dart';
import 'tflite_engine.dart';

/// 모델 형식 열거형
enum ModelFormat {
  gguf,
  onnx,
  tflite,
  unknown,
}

/// 모델 팩토리
/// 
/// 모델 파일의 형식을 자동으로 감지하고
/// 적절한 추론 엔진을 생성합니다.
class ModelFactory {
  /// 파일 확장자로 모델 형식 감지
  static ModelFormat detectFormatByExtension(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'gguf':
        return ModelFormat.gguf;
      case 'onnx':
        return ModelFormat.onnx;
      case 'tflite':
      case 'lite':
        return ModelFormat.tflite;
      default:
        return ModelFormat.unknown;
    }
  }
  
  /// 파일 매직 넘버로 모델 형식 감지
  static Future<ModelFormat> detectFormatByMagicNumber(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ModelFormat.unknown;
      }
      
      // 처음 8바이트 읽기
      final bytes = await file.openRead(0, 8).expand((chunk) => chunk).toList();
      if (bytes.length < 4) {
        return ModelFormat.unknown;
      }
      
      final uint8List = Uint8List.fromList(bytes);
      final magic = ByteData.sublistView(uint8List, 0, 4).getUint32(0, Endian.little);
      
      // GGUF 매직 넘버: 0x46554747 ("GGUF")
      if (magic == 0x46554747) {
        return ModelFormat.gguf;
      }
      
      // TFLite 매직 넘버: 0x54464C33 ("TFL3")
      if (magic == 0x54464C33) {
        return ModelFormat.tflite;
      }
      
      // ONNX는 Protobuf 형식이므로 확장자로 판단
      if (filePath.toLowerCase().endsWith('.onnx')) {
        return ModelFormat.onnx;
      }
      
      return ModelFormat.unknown;
    } catch (e) {
      print('매직 넘버 감지 실패: $e');
      return ModelFormat.unknown;
    }
  }
  
  /// 모델 형식 자동 감지 (확장자 + 매직 넘버)
  static Future<ModelFormat> detectFormat(String filePath) async {
    // 1. 확장자로 먼저 시도
    final formatByExt = detectFormatByExtension(filePath);
    if (formatByExt != ModelFormat.unknown) {
      // 2. 매직 넘버로 검증
      final formatByMagic = await detectFormatByMagicNumber(filePath);
      if (formatByMagic != ModelFormat.unknown) {
        return formatByMagic;
      }
      return formatByExt;
    }
    
    // 3. 매직 넘버로만 판단
    return await detectFormatByMagicNumber(filePath);
  }
  
  /// 적절한 추론 엔진 생성
  static Future<InferenceEngine> createEngine(String modelPath) async {
    final format = await detectFormat(modelPath);
    
    print('감지된 모델 형식: $format');
    
    switch (format) {
      case ModelFormat.gguf:
        print('GGUF 엔진 생성');
        return GGUFInferenceEngine();
      
      case ModelFormat.onnx:
        print('ONNX 엔진 생성');
        return ONNXInferenceEngine();
      
      case ModelFormat.tflite:
        print('TFLite 엔진 생성');
        return TFLiteInferenceEngine();
      
      case ModelFormat.unknown:
        throw Exception('지원하지 않는 모델 형식입니다: $modelPath');
    }
  }
  
  /// 모델 형식 이름 가져오기
  static String getFormatName(ModelFormat format) {
    switch (format) {
      case ModelFormat.gguf:
        return 'GGUF (llama.cpp)';
      case ModelFormat.onnx:
        return 'ONNX Runtime';
      case ModelFormat.tflite:
        return 'TensorFlow Lite';
      case ModelFormat.unknown:
        return 'Unknown';
    }
  }
  
  /// 모델 형식별 지원 확장자 목록
  static List<String> getSupportedExtensions() {
    return ['.gguf', '.onnx', '.tflite', '.lite'];
  }
  
  /// 모델 형식별 설명
  static String getFormatDescription(ModelFormat format) {
    switch (format) {
      case ModelFormat.gguf:
        return 'llama.cpp 기반 양자화 모델\n'
               '- 메모리 효율적\n'
               '- 다양한 LLM 지원\n'
               '- 완전한 스트리밍';
      
      case ModelFormat.onnx:
        return 'ONNX Runtime 기반 모델\n'
               '- 크로스 플랫폼\n'
               '- 하드웨어 가속\n'
               '- 다양한 모델 지원';
      
      case ModelFormat.tflite:
        return 'TensorFlow Lite 모델\n'
               '- 모바일 최적화\n'
               '- GPU 가속\n'
               '- 경량화';
      
      case ModelFormat.unknown:
        return '지원하지 않는 형식';
    }
  }
}
