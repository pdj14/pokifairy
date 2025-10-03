import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:ffi/ffi.dart';

// llama.cpp 구조체 정의 (간단한 버전)
final class LlamaModelParams extends Struct {
  external Pointer devices;
  external Pointer tensorBuftOverrides;
  @Int32()
  external int nGpuLayers;
  @Int32()
  external int splitMode;
  @Int32()
  external int mainGpu;
  external Pointer tensorSplit;
  external Pointer progressCallback;
  external Pointer progressCallbackUserData;
  external Pointer kvOverrides;
  @Int8()
  external int vocabOnly;
  @Int8()
  external int useMemoryMapping;
  @Int8()
  external int useMemoryLocking;
  @Int8()
  external int checkTensors;
  @Int8()
  external int useExtraBufts;
}

// llama_batch 구조체 정의 (정확한 C 구조체와 일치)
final class LlamaBatch extends Struct {
  @Int32() external int nTokens;           // int32_t n_tokens
  external Pointer<Int32> token;           // llama_token * token
  external Pointer<Float> embd;            // float * embd
  external Pointer<Int32> pos;             // llama_pos * pos
  external Pointer<Int32> nSeqId;          // int32_t * n_seq_id
  external Pointer<Pointer<Int32>> seqId;  // llama_seq_id ** seq_id
  external Pointer<Int8> logits;           // int8_t * logits
}

// llama_candidates 구조체 정의
final class LlamaCandidates extends Struct {
  @Int32() external int nCandidates;       // int32_t n_candidates
  external Pointer<Int32> token;           // llama_token * token
  external Pointer<Float> logit;           // float * logit
  external Pointer<Float> p;               // float * p
  external Pointer<Float> logitRescored;   // float * logit_rescored
  external Pointer<Float> pRescored;       // float * p_rescored
  external Pointer<Int8> logits;           // int8_t * logits
  external Pointer<Int8> allLogits;        // int8_t all_logits
}

// llama_context 구조체 정의 (간단한 버전)
final class LlamaContext extends Struct {
  @Int32() external int dummy; // 빈 구조체 방지를 위한 더미 필드
}

// llama_model 구조체 정의 (간단한 버전)
final class LlamaModel extends Struct {
  @Int32() external int dummy; // 빈 구조체 방지를 위한 더미 필드
}

// llama_context_params 구조체 정의 (실제 C 구조체와 일치)
final class LlamaContextParams extends Struct {
  @Uint32()
  external int nCtx;                    // uint32_t n_ctx
  @Uint32()
  external int nBatch;                  // uint32_t n_batch
  @Uint32()
  external int nUbatch;                 // uint32_t n_ubatch
  @Uint32()
  external int nSeqMax;                 // uint32_t n_seq_max
  @Int32()
  external int nThreads;                // int32_t n_threads
  @Int32()
  external int nThreadsBatch;           // int32_t n_threads_batch
  
  @Int32()
  external int ropeScalingType;         // enum llama_rope_scaling_type rope_scaling_type
  @Int32()
  external int poolingType;             // enum llama_pooling_type pooling_type
  @Int32()
  external int attentionType;           // enum llama_attention_type attention_type
  @Int32()
  external int flashAttnType;           // enum llama_flash_attn_type flash_attn_type
  
  @Float()
  external double ropeFreqBase;         // float rope_freq_base
  @Float()
  external double ropeFreqScale;        // float rope_freq_scale
  @Float()
  external double yarnExtFactor;        // float yarn_ext_factor
  @Float()
  external double yarnAttnFactor;       // float yarn_attn_factor
  @Float()
  external double yarnBetaFast;         // float yarn_beta_fast
  @Float()
  external double yarnBetaSlow;         // float yarn_beta_slow
  @Uint32()
  external int yarnOrigCtx;             // uint32_t yarn_orig_ctx
  @Float()
  external double defragThold;          // float defrag_thold
  
  external Pointer cbEval;              // ggml_backend_sched_eval_callback cb_eval
  external Pointer cbEvalUserData;      // void * cb_eval_user_data
  
  @Int32()
  external int typeK;                   // enum ggml_type type_k
  @Int32()
  external int typeV;                   // enum ggml_type type_v
  
  external Pointer abortCallback;       // ggml_abort_callback abort_callback
  external Pointer abortCallbackData;   // void * abort_callback_data
  
  @Int8()
  external int embeddings;              // bool embeddings
  @Int8()
  external int offloadKqv;              // bool offload_kqv
  @Int8()
  external int noPerf;                  // bool no_perf
  @Int8()
  external int opOffload;               // bool op_offload
  @Int8()
  external int swaFull;                 // bool swa_full
  @Int8()
  external int kvUnified;               // bool kv_unified
}

// llama.cpp C 함수 시그니처 정의 (libllama.so에서 직접 호출)
typedef LlamaBackendInitC = Void Function();
typedef LlamaBackendInitDart = void Function();

typedef LlamaModelDefaultParamsC = LlamaModelParams Function();
typedef LlamaModelDefaultParamsDart = LlamaModelParams Function();

typedef LlamaContextDefaultParamsC = LlamaContextParams Function();
typedef LlamaContextDefaultParamsDart = LlamaContextParams Function();

typedef LlamaModelLoadFromFileC = Pointer Function(Pointer<Utf8> path, LlamaModelParams params);
typedef LlamaModelLoadFromFileDart = Pointer Function(Pointer<Utf8> path, LlamaModelParams params);

typedef LlamaInitFromModelC = Pointer Function(Pointer model, LlamaContextParams params);
typedef LlamaInitFromModelDart = Pointer Function(Pointer model, LlamaContextParams params);

typedef LlamaTokenizeC = Int32 Function(Pointer vocab, Pointer<Utf8> text, Int32 textLen, Pointer<Int32> tokens, Int32 nMaxTokens, Bool addBos, Bool special);
typedef LlamaTokenizeDart = int Function(Pointer vocab, Pointer<Utf8> text, int textLen, Pointer<Int32> tokens, int nMaxTokens, bool addBos, bool special);

typedef LlamaVocabGetTextC = Pointer<Utf8> Function(Pointer vocab, Int32 token);
typedef LlamaVocabGetTextDart = Pointer<Utf8> Function(Pointer vocab, int token);

typedef LlamaFreeC = Void Function(Pointer ctx);
typedef LlamaFreeDart = void Function(Pointer ctx);

typedef LlamaModelFreeC = Void Function(Pointer model);
typedef LlamaModelFreeDart = void Function(Pointer model);

typedef LlamaModelDescC = Int32 Function(Pointer model, Pointer<Utf8> buf, IntPtr bufSize);
typedef LlamaModelDescDart = int Function(Pointer model, Pointer<Utf8> buf, int bufSize);

typedef LlamaModelGetVocabC = Pointer Function(Pointer model);
typedef LlamaModelGetVocabDart = Pointer Function(Pointer model);

// 실제 추론을 위한 추가 함수들
typedef LlamaDecodeC = Int32 Function(Pointer ctx, LlamaBatch batch);
typedef LlamaDecodeDart = int Function(Pointer ctx, LlamaBatch batch);

typedef LlamaBatchInitC = LlamaBatch Function(Int32 nTokens, Int32 embd, Int32 nSeqMax);
typedef LlamaBatchInitDart = LlamaBatch Function(int nTokens, int embd, int nSeqMax);

typedef LlamaBatchGetOneC = LlamaBatch Function(Pointer<Int32> tokens, Int32 nTokens);
typedef LlamaBatchGetOneDart = LlamaBatch Function(Pointer<Int32> tokens, int nTokens);

typedef LlamaBatchFreeC = Void Function(LlamaBatch batch);
typedef LlamaBatchFreeDart = void Function(LlamaBatch batch);

typedef LlamaSamplerInitC = Pointer Function(Pointer ctx);
typedef LlamaSamplerInitDart = Pointer Function(Pointer ctx);

typedef LlamaSamplerSampleC = Int32 Function(Pointer sampler, Pointer ctx, Int32 idx);
typedef LlamaSamplerSampleDart = int Function(Pointer sampler, Pointer ctx, int idx);

typedef LlamaSamplerFreeC = Void Function(Pointer sampler);
typedef LlamaSamplerFreeDart = void Function(Pointer sampler);

typedef LlamaGetLogitsIthC = Pointer<Float> Function(Pointer ctx, Int32 i);
typedef LlamaGetLogitsIthDart = Pointer<Float> Function(Pointer ctx, int i);

typedef LlamaGetLogitsC = Pointer<Float> Function(Pointer ctx);
typedef LlamaGetLogitsDart = Pointer<Float> Function(Pointer ctx);

typedef LlamaVocabNTokensC = Int32 Function(Pointer vocab);
typedef LlamaVocabNTokensDart = int Function(Pointer vocab);

typedef LlamaVocabIsEogC = Uint8 Function(Pointer vocab, Int32 token);
typedef LlamaVocabIsEogDart = int Function(Pointer vocab, int token);

typedef LlamaDetokenizeC = Int32 Function(Pointer vocab, Pointer<Int32> tokens, Int32 nTokens, Pointer<Utf8> text, Int32 textLenMax, Uint8 removeSpecial, Uint8 unparseSpecial);
typedef LlamaDetokenizeDart = int Function(Pointer vocab, Pointer<Int32> tokens, int nTokens, Pointer<Utf8> text, int textLenMax, int removeSpecial, int unparseSpecial);

typedef LlamaNCtxC = Uint32 Function(Pointer ctx);
typedef LlamaNCtxDart = int Function(Pointer ctx);

// 추가 함수들
typedef LlamaCandidatesFromPC = Pointer<LlamaCandidates> Function(Pointer<LlamaContext> ctx);
typedef LlamaCandidatesFromPDart = Pointer<LlamaCandidates> Function(Pointer<LlamaContext> ctx);

typedef LlamaSampleTokenGreedyC = Int32 Function(Pointer<LlamaCandidates> candidates);
typedef LlamaSampleTokenGreedyDart = int Function(Pointer<LlamaCandidates> candidates);

typedef LlamaCandidatesFreeC = Void Function(Pointer<LlamaCandidates> candidates);
typedef LlamaCandidatesFreeDart = void Function(Pointer<LlamaCandidates> candidates);

typedef LlamaTokenEosC = Int32 Function(Pointer<LlamaModel> model);
typedef LlamaTokenEosDart = int Function(Pointer<LlamaModel> model);

/// llama.cpp 네이티브 라이브러리와의 FFI 바인딩
class NativeBindings {
  static NativeBindings? _instance;
  static NativeBindings get instance => _instance ??= NativeBindings._();
  
  NativeBindings._();
  
  DynamicLibrary? _lib;
  bool _isInitialized = false;
  Pointer? _model;
  Pointer? _context;
  
  // llama.cpp 함수 포인터들
  late LlamaBackendInitDart _llamaBackendInit;
  late LlamaModelDefaultParamsDart _llamaModelDefaultParams;
  late LlamaContextDefaultParamsDart _llamaContextDefaultParams;
  late LlamaModelLoadFromFileDart _llamaModelLoadFromFile;
  late LlamaInitFromModelDart _llamaInitFromModel;
  late LlamaTokenizeDart _llamaTokenize;
  late LlamaVocabGetTextDart _llamaVocabGetText;
  late LlamaFreeDart _llamaFree;
  late LlamaModelFreeDart _llamaModelFree;
  late LlamaModelDescDart _llamaModelDesc;
  late LlamaModelGetVocabDart _llamaModelGetVocab;
  
  // 실제 추론을 위한 함수 포인터들
  late LlamaDecodeDart _llamaDecode;
  late LlamaBatchInitDart _llamaBatchInit;
  late LlamaBatchGetOneDart _llamaBatchGetOne;
  late LlamaBatchFreeDart _llamaBatchFree;
  late LlamaSamplerInitDart _llamaSamplerInit;
  late LlamaSamplerSampleDart _llamaSamplerSample;
  late LlamaSamplerFreeDart _llamaSamplerFree;
  late LlamaGetLogitsIthDart _llamaGetLogitsIth;
  late LlamaGetLogitsDart _llamaGetLogits;
  late LlamaVocabNTokensDart _llamaVocabNTokens;
  late LlamaVocabIsEogDart _llamaVocabIsEog;
  late LlamaDetokenizeDart _llamaDetokenize;
  late LlamaNCtxDart _llamaNCtx;
  
  // 추가 함수 포인터들
  late LlamaCandidatesFromPDart _llamaCandidatesFromP;
  late LlamaSampleTokenGreedyDart _llamaSampleTokenGreedy;
  late LlamaCandidatesFreeDart _llamaCandidatesFree;
  late LlamaTokenEosDart _llamaTokenEos;
  
  /// FFI 바인딩 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _lib = _loadNativeLibrary();
      if (_lib == null) {
        print('네이티브 라이브러리 로드 실패');
        return false;
      }
      
      _bindNativeFunctions();
      
      // llama.cpp 백엔드 초기화 (안전하게)
      try {
        _llamaBackendInit();
        print('llama.cpp 백엔드 초기화 성공');
      } catch (e) {
        print('llama.cpp 백엔드 초기화 실패: $e');
        return false;
      }
      
      _isInitialized = true;
      print('FFI 바인딩 초기화 완료');
      return true;
    } catch (e) {
      print('FFI 바인딩 초기화 실패: $e');
      return false;
    }
  }
  
  /// 플랫폼별 네이티브 라이브러리 로드
  DynamicLibrary? _loadNativeLibrary() {
    try {
      if (Platform.isAndroid) {
        // Android에서 libllama.so 로드
        return DynamicLibrary.open('libllama.so');
      } else if (Platform.isIOS) {
        // iOS에서는 정적 링크된 라이브러리 사용
        return DynamicLibrary.process();
      } else {
        throw UnsupportedError('지원되지 않는 플랫폼: ${Platform.operatingSystem}');
      }
    } catch (e) {
      print('네이티브 라이브러리 로드 실패: $e');
      print('플랫폼: ${Platform.operatingSystem}');
      return null;
    }
  }
  
  /// 네이티브 함수들을 Dart 함수로 바인딩
  void _bindNativeFunctions() {
    if (_lib == null) throw Exception('라이브러리가 로드되지 않았습니다');
    
    try {
      // llama.cpp 함수들 바인딩
      _llamaBackendInit = _lib!
          .lookup<NativeFunction<LlamaBackendInitC>>('llama_backend_init')
          .asFunction();
      
      _llamaModelDefaultParams = _lib!
          .lookup<NativeFunction<LlamaModelDefaultParamsC>>('llama_model_default_params')
          .asFunction();
      
      _llamaContextDefaultParams = _lib!
          .lookup<NativeFunction<LlamaContextDefaultParamsC>>('llama_context_default_params')
          .asFunction();
      
      _llamaModelLoadFromFile = _lib!
          .lookup<NativeFunction<LlamaModelLoadFromFileC>>('llama_model_load_from_file')
          .asFunction();
      
      _llamaInitFromModel = _lib!
          .lookup<NativeFunction<LlamaInitFromModelC>>('llama_init_from_model')
          .asFunction();
      
      _llamaTokenize = _lib!
          .lookup<NativeFunction<LlamaTokenizeC>>('llama_tokenize')
          .asFunction();
      
      _llamaVocabGetText = _lib!
          .lookup<NativeFunction<LlamaVocabGetTextC>>('llama_vocab_get_text')
          .asFunction();
      
      _llamaFree = _lib!
          .lookup<NativeFunction<LlamaFreeC>>('llama_free')
          .asFunction();
      
      _llamaModelFree = _lib!
          .lookup<NativeFunction<LlamaModelFreeC>>('llama_model_free')
          .asFunction();
      
      _llamaModelDesc = _lib!
          .lookup<NativeFunction<LlamaModelDescC>>('llama_model_desc')
          .asFunction();
      
      _llamaModelGetVocab = _lib!
          .lookup<NativeFunction<LlamaModelGetVocabC>>('llama_model_get_vocab')
          .asFunction();
      
      // 실제 추론을 위한 함수들 바인딩
      _llamaDecode = _lib!
          .lookup<NativeFunction<LlamaDecodeC>>('llama_decode')
          .asFunction();
      
      _llamaBatchInit = _lib!
          .lookup<NativeFunction<LlamaBatchInitC>>('llama_batch_init')
          .asFunction();
      
      _llamaBatchGetOne = _lib!
          .lookup<NativeFunction<LlamaBatchGetOneC>>('llama_batch_get_one')
          .asFunction();
      
      _llamaBatchFree = _lib!
          .lookup<NativeFunction<LlamaBatchFreeC>>('llama_batch_free')
          .asFunction();
      
      _llamaSamplerInit = _lib!
          .lookup<NativeFunction<LlamaSamplerInitC>>('llama_sampler_init')
          .asFunction();
      
      _llamaSamplerSample = _lib!
          .lookup<NativeFunction<LlamaSamplerSampleC>>('llama_sampler_sample')
          .asFunction();
      
      _llamaSamplerFree = _lib!
          .lookup<NativeFunction<LlamaSamplerFreeC>>('llama_sampler_free')
          .asFunction();
      
      _llamaGetLogitsIth = _lib!
          .lookup<NativeFunction<LlamaGetLogitsIthC>>('llama_get_logits_ith')
          .asFunction();
      
      _llamaGetLogits = _lib!
          .lookup<NativeFunction<LlamaGetLogitsC>>('llama_get_logits')
          .asFunction();
      
      _llamaVocabNTokens = _lib!
          .lookup<NativeFunction<LlamaVocabNTokensC>>('llama_vocab_n_tokens')
          .asFunction();

      _llamaVocabIsEog = _lib!
          .lookup<NativeFunction<LlamaVocabIsEogC>>('llama_vocab_is_eog')
          .asFunction();

      _llamaDetokenize = _lib!
          .lookup<NativeFunction<LlamaDetokenizeC>>('llama_detokenize')
          .asFunction();

      _llamaNCtx = _lib!
          .lookup<NativeFunction<LlamaNCtxC>>('llama_n_ctx')
          .asFunction();
      
      // 추가 함수들 바인딩
      try {
        _llamaCandidatesFromP = _lib!
            .lookup<NativeFunction<LlamaCandidatesFromPC>>('llama_candidates_from_p')
            .asFunction();
        
        _llamaSampleTokenGreedy = _lib!
            .lookup<NativeFunction<LlamaSampleTokenGreedyC>>('llama_sample_token_greedy')
            .asFunction();
        
        _llamaCandidatesFree = _lib!
            .lookup<NativeFunction<LlamaCandidatesFreeC>>('llama_candidates_free')
            .asFunction();
        
        _llamaTokenEos = _lib!
            .lookup<NativeFunction<LlamaTokenEosC>>('llama_token_eos')
            .asFunction();
      } catch (e) {
        print('추가 함수 바인딩 실패 (일부 함수가 없을 수 있음): $e');
        // 기본값으로 설정
        _llamaCandidatesFromP = (ctx) => nullptr;
        _llamaSampleTokenGreedy = (candidates) => 0;
        _llamaCandidatesFree = (candidates) {};
        _llamaTokenEos = (model) => 0;
      }
      
      print('llama.cpp 함수 바인딩 완료');
    } catch (e) {
      print('함수 바인딩 실패: $e');
      rethrow;
    }
  }
  
  /// llama.cpp 백엔드 초기화 (이미 initialize()에서 호출됨)
  Future<bool> initializeLlama() async {
    return _isInitialized;
  }
  
  /// 모델 파일 로드
  Future<bool> loadModel(String modelPath) async {
    if (!_isInitialized) return false;
    
    try {
      // 기존 모델/컨텍스트 정리
      _cleanup();
      
      // 모델 로드 (params를 by-value로 전달)
      final pathPtr = modelPath.toNativeUtf8();
      final modelParams = _llamaModelDefaultParams();
      _model = _llamaModelLoadFromFile(pathPtr, modelParams);
      malloc.free(pathPtr);
      
      if (_model == nullptr) {
        print('모델 로드 실패: $_model');
        return false;
      }
      
      // 컨텍스트 초기화 (params를 by-value로 전달)
      final contextParams = _llamaContextDefaultParams();
      _context = _llamaInitFromModel(_model!, contextParams);
      
      if (_context == nullptr) {
        print('컨텍스트 초기화 실패');
        _llamaModelFree(_model!);
        _model = null;
        return false;
      }
      
      print('모델 로드 성공: $modelPath');
      return true;
    } catch (e) {
      print('모델 로드 실패: $e');
      return false;
    }
  }
  
  /// 스트리밍 텍스트 생성 (초등학생용)
  Stream<String> generateTextStream(String prompt, {int maxTokens = 1024, int minTokensBeforeEog = 32, bool autoContinue = true, int maxTotalTokens = 4096, bool respectShortAnswers = true}) async* {
    if (!_isInitialized || _model == null || _context == null) {
      yield 'FFI가 초기화되지 않았거나 모델이 로드되지 않았습니다';
      return;
    }
    
    try {
      // vocab 가져오기
      final vocab = _llamaModelGetVocab(_model!);
      if (vocab == nullptr) {
        yield 'vocab을 가져올 수 없습니다';
        return;
      }
      
      // 프롬프트 토큰화
      final promptPtr = prompt.toNativeUtf8();
      final tokens = malloc<Int32>(512); // 최대 512 토큰
      
      final textLenBytes = utf8.encode(prompt).length;
      final tokenCount = _llamaTokenize(
        vocab,
        promptPtr,
        textLenBytes,
        tokens,
        512,
        true, // add_bos
        false, // special
      );
      
      if (tokenCount < 0) {
        malloc.free(promptPtr);
        malloc.free(tokens);
        yield '토큰화 실패';
        return;
      }
      
      // 실제 AI 추론 시도 (llama_batch_get_one 사용 - 더 안전한 방법)
      try {
        print('실제 AI 추론 시작 - llama_batch_get_one 사용');
        
        // 1. 안전한 토큰 처리 (메모리 오류 방지)
        print('안전한 토큰 처리 시작 (토큰 수: $tokenCount)');
        
        // 4. 안전한 토큰 처리 (메모리 오류 방지)
        bool allTokensProcessed = true;
        int lastDecodeResult = 0;
        int minEog = minTokensBeforeEog;
        bool autoCont = autoContinue;
        if (respectShortAnswers) {
          minEog = 0;
          autoCont = false;
        }
        
        // 프롬프트 배치: helper 사용 (llama_batch_get_one)
        print('프롬프트 배치 구성 시작 (ubatch get_one)...');
        const int chunkSize = 32; // 작은 단위로 나눠 디코드하여 KV 슬롯 문제 회피
        int processed = 0;
        allTokensProcessed = true;
        while (processed < tokenCount) {
          final remain = tokenCount - processed;
          final cur = remain < chunkSize ? remain : chunkSize;
          final chunkPtr = malloc<Int32>(cur);
          for (int i = 0; i < cur; i++) {
            chunkPtr[i] = tokens[processed + i];
          }
          final batch = _llamaBatchGetOne(chunkPtr, cur);
          if (batch.logits != nullptr) {
            for (int i = 0; i < cur; i++) {
              batch.logits[i] = (i == cur - 1) ? 1 : 0;
            }
          }
          print('llama_decode 호출 시작 (프롬프트 ubatch: $processed~${processed + cur - 1})');
          final dr = _llamaDecode(_context!, batch);
          malloc.free(chunkPtr);
          print('llama_decode 결과: $dr');
          if (dr != 0) {
            allTokensProcessed = false;
            lastDecodeResult = dr;
            break;
          }
          processed += cur;
        }
        
        print('모든 토큰 처리 시뮬레이션 완료');

        if (allTokensProcessed) {
          final vocab = _llamaModelGetVocab(_model!);
          final generated = <int>[];
          int steps = 0;
          // 컨텍스트 크기에 맞춰 총 생성 한도 계산 (여유 margin 보유)
          final ctxSize = _llamaNCtx(_context!);
          final margin = 16;
          final promptTokens = tokenCount;
          final maxByCtx = ctxSize - promptTokens - margin;
          final hardTotalCap = maxByCtx > 0 ? maxByCtx : maxTotalTokens;

          // 내부 함수: 한 스텝 생성
          Future<bool> generateOneStep({required bool ignoreEog}) async {
            final logitsPtr = _llamaGetLogitsIth(_context!, -1);
            if (logitsPtr == nullptr) {
              print('스트리밍: logitsPtr이 null입니다');
              return false;
            }

            final nVocab = _llamaVocabNTokens(vocab);
            print('스트리밍: vocab 크기: $nVocab');
            
            int bestId = -1;
            double bestLogit = -double.maxFinite;
            int secondId = -1;
            double secondLogit = -double.maxFinite;
            
            // 로그its에서 최고 점수 토큰 찾기
            for (int i = 0; i < nVocab; i++) {
              final v = logitsPtr.elementAt(i).value.toDouble();
              if (v > bestLogit) {
                secondLogit = bestLogit; secondId = bestId;
                bestLogit = v; bestId = i;
              } else if (v > secondLogit) {
                secondLogit = v; secondId = i;
              }
            }

            print('스트리밍: 최고 토큰 ID: $bestId, 로그it: $bestLogit');

            // 너무 이른 EOG 방지: 초기 N토큰 동안은 EOG를 무시하고 차선 토큰 사용
            if (steps < minEog && bestId != -1 && _llamaVocabIsEog(vocab, bestId) != 0) {
              if (secondId != -1) {
                print('스트리밍: EOG 토큰을 차선 토큰으로 대체: $bestId -> $secondId');
                bestId = secondId;
              }
            }

            // EOG 처리: auto-continue 구간에서는 차선 토큰으로 대체 시도
            if (bestId != -1 && _llamaVocabIsEog(vocab, bestId) != 0) {
              if (ignoreEog && secondId != -1) {
                print('스트리밍: EOG 토큰을 차선 토큰으로 대체 (auto-continue): $bestId -> $secondId');
                bestId = secondId;
              } else {
                print('스트리밍: EOG 토큰으로 인해 생성 중단');
                return false;
              }
            }

            if (bestId == -1) {
              print('스트리밍: 유효한 토큰을 찾을 수 없습니다');
              return false;
            }

            generated.add(bestId);
            print('스트리밍: 토큰 $bestId 추가, 총 생성된 토큰: ${generated.length}');

            final oneToken = malloc<Int32>(1);
            oneToken[0] = bestId;
            final stepBatch = _llamaBatchGetOne(oneToken, 1);
            if (stepBatch.logits != nullptr) {
              stepBatch.logits[0] = 1;
            }
            final r = _llamaDecode(_context!, stepBatch);
            malloc.free(oneToken);
            if (r != 0) {
              print('스트리밍: llama_decode 실패: $r');
              return false;
            }
            steps++;
            
            // UI가 블록되지 않도록 주기적으로 yield
            if (steps % 3 == 0) {
              await Future.delayed(const Duration(milliseconds: 1));
            }
            
            return true;
          }

          // 스트리밍을 위한 버퍼
          String currentText = '';
          int lastYieldedLength = 0;
          
          // 반복 패턴 감지를 위한 변수들
          List<String> recentTokens = [];
          int repetitionCount = 0;
          const int maxRecentTokens = 10;
          const int maxRepetitionThreshold = 3;
          
          // 전체 생성된 텍스트 추적
          String fullGeneratedText = '';
          int consecutiveSkips = 0;
          const int maxConsecutiveSkips = 5;

          // 1차 루프: maxTokens까지 생성
          while (steps < maxTokens && steps < hardTotalCap) {
            if (!(await generateOneStep(ignoreEog: false))) break;
            
            // 주기적으로 텍스트를 스트리밍으로 전송
            if (generated.isNotEmpty && steps % 5 == 0) {
              final genPtr = malloc<Int32>(generated.length);
              for (int i = 0; i < generated.length; i++) {
                genPtr[i] = generated[i];
              }
              int cap = 8192;
              Pointer<Uint8> outBuf = malloc<Uint8>(cap);
              int wrote = _llamaDetokenize(
                vocab,
                genPtr,
                generated.length,
                outBuf.cast<Utf8>(),
                cap,
                1, // remove_special
                1, // unparse_special
              );
              if (wrote < 0) {
                // 필요한 크기만큼 재할당 후 재시도
                malloc.free(outBuf);
                cap = -wrote + 4;
                outBuf = malloc<Uint8>(cap);
                wrote = _llamaDetokenize(
                  vocab,
                  genPtr,
                  generated.length,
                  outBuf.cast<Utf8>(),
                  cap,
                  1,
                  1,
                );
              }
              if (wrote > 0) {
                final bytes = outBuf.asTypedList(wrote);
                currentText = utf8.decode(bytes, allowMalformed: true);
                
                // 새로운 텍스트가 있으면 스트리밍으로 전송
                if (currentText.length > lastYieldedLength) {
                  final newText = currentText.substring(lastYieldedLength);
                  
                  // 금지 단어 리스트로 간단한 필터링
                  const List<String> forbiddenWords = [
                    '```',
                    'python',
                    'def',
                    'solve',
                    '질문:',
                    '지키미:',
                    '답변:',
                    'print'
                  ];
                  
                  bool shouldSkip = false;
                  final trimmedText = newText.trim();
                  
                  // 코드 블록이 포함된 경우 정상적인 대화 부분만 추출
                  if (trimmedText.contains('```')) {
                    // 코드 블록 시작 전까지의 텍스트만 추출
                    final codeBlockIndex = trimmedText.indexOf('```');
                    if (codeBlockIndex > 0) {
                      final cleanText = trimmedText.substring(0, codeBlockIndex).trim();
                      if (cleanText.isNotEmpty) {
                        print('코드 블록 감지, 정상 대화 부분만 전송: "$cleanText"');
                        yield cleanText;
                        return; // 코드 블록이 있으면 여기서 종료
                      }
                    }
                    print('코드 블록 감지: "$trimmedText" - 스킵');
                    shouldSkip = true;
                  } else {
                    // 다른 금지 단어들 체크
                    for (final word in forbiddenWords) {
                      if (word != '```' && trimmedText.contains(word)) {
                        print('불필요한 패턴 감지: "$trimmedText" - 매칭된 단어: "$word"');
                        shouldSkip = true;
                        break;
                      }
                    }
                  }
                  
                  if (shouldSkip) {
                    print('불필요한 패턴 감지: "$newText" - 스킵');
                    consecutiveSkips++;
                    if (consecutiveSkips >= maxConsecutiveSkips) {
                      print('연속 스킵 한도 초과 ($consecutiveSkips회) - 생성 중단');
                      malloc.free(outBuf);
                      malloc.free(genPtr);
                      return;
                    }
                    continue;
                  }
                  
                  // 유효한 텍스트가 나오면 스킵 카운터 리셋
                  consecutiveSkips = 0;
                  
                  // 반복 패턴 감지
                  final words = newText.trim().split(RegExp(r'\s+'));
                  for (final word in words) {
                    if (word.isNotEmpty) {
                      recentTokens.add(word);
                      if (recentTokens.length > maxRecentTokens) {
                        recentTokens.removeAt(0);
                      }
                      
                      // 반복 패턴 체크
                      if (recentTokens.length >= 4) {
                        final lastFour = recentTokens.sublist(recentTokens.length - 4);
                        final pattern = lastFour.join(' ');
                        int patternCount = 0;
                        
                        for (int i = 0; i <= recentTokens.length - 4; i++) {
                          final checkPattern = recentTokens.sublist(i, i + 4).join(' ');
                          if (checkPattern == pattern) {
                            patternCount++;
                          }
                        }
                        
                        if (patternCount >= maxRepetitionThreshold) {
                          print('반복 패턴 감지: "$pattern" (${patternCount}회) - 생성 중단');
                          malloc.free(outBuf);
                          malloc.free(genPtr);
                          return;
                        }
                      }
                    }
                  }
                  
                  print('스트리밍 전송: "$newText"');
                  yield newText;
                  lastYieldedLength = currentText.length;
                }
              }
              malloc.free(outBuf);
              malloc.free(genPtr);
            }
            
            // UI가 블록되지 않도록 더 자주 yield
            await Future.delayed(const Duration(milliseconds: 10));
          }

          // 1차 루프 완료 후 남은 텍스트 전송
          if (generated.isNotEmpty) {
            final genPtr = malloc<Int32>(generated.length);
            for (int i = 0; i < generated.length; i++) {
              genPtr[i] = generated[i];
            }
            int cap = 8192;
            Pointer<Uint8> outBuf = malloc<Uint8>(cap);
            int wrote = _llamaDetokenize(
              vocab,
              genPtr,
              generated.length,
              outBuf.cast<Utf8>(),
              cap,
              1, // remove_special
              1, // unparse_special
            );
            if (wrote < 0) {
              // 필요한 크기만큼 재할당 후 재시도
              malloc.free(outBuf);
              cap = -wrote + 4;
              outBuf = malloc<Uint8>(cap);
              wrote = _llamaDetokenize(
                vocab,
                genPtr,
                generated.length,
                outBuf.cast<Utf8>(),
                cap,
                1,
                1,
              );
            }
            if (wrote > 0) {
              final bytes = outBuf.asTypedList(wrote);
              currentText = utf8.decode(bytes, allowMalformed: true);
              
              // 남은 텍스트가 있으면 전송
              if (currentText.length > lastYieldedLength) {
                final remainingText = currentText.substring(lastYieldedLength);
                print('1차 루프 완료 후 남은 텍스트 전송: "$remainingText"');
                yield remainingText;
                lastYieldedLength = currentText.length;
              }
            }
            malloc.free(outBuf);
            malloc.free(genPtr);
          }

          // 자동 이어쓰기: EOG가 아니고 총 토큰 한도 내면 계속
          if (autoCont) {
            print('자동 이어쓰기 시작 - 현재 토큰: $steps, 한도: $maxTotalTokens');
            while (steps < maxTotalTokens && steps < hardTotalCap) {
              if (!(await generateOneStep(ignoreEog: true))) {
                print('자동 이어쓰기 중단 - EOG 토큰 발견');
                break;
              }
              
              // 매 스텝마다 텍스트를 스트리밍으로 전송
              if (generated.isNotEmpty) {
                final genPtr = malloc<Int32>(generated.length);
                for (int i = 0; i < generated.length; i++) {
                  genPtr[i] = generated[i];
                }
                int cap = 8192;
                Pointer<Uint8> outBuf = malloc<Uint8>(cap);
                int wrote = _llamaDetokenize(
                  vocab,
                  genPtr,
                  generated.length,
                  outBuf.cast<Utf8>(),
                  cap,
                  1, // remove_special
                  1, // unparse_special
                );
                if (wrote < 0) {
                  // 필요한 크기만큼 재할당 후 재시도
                  malloc.free(outBuf);
                  cap = -wrote + 4;
                  outBuf = malloc<Uint8>(cap);
                  wrote = _llamaDetokenize(
                    vocab,
                    genPtr,
                    generated.length,
                    outBuf.cast<Utf8>(),
                    cap,
                    1,
                    1,
                  );
                }
                if (wrote > 0) {
                  final bytes = outBuf.asTypedList(wrote);
                  currentText = utf8.decode(bytes, allowMalformed: true);
                  
                  // 새로운 텍스트가 있으면 스트리밍으로 전송
                  if (currentText.length > lastYieldedLength) {
                    final newText = currentText.substring(lastYieldedLength);
                    
                    // 금지 단어 리스트로 간단한 필터링 (자동 이어쓰기)
                    const List<String> forbiddenWords = [
                      '```',
                      'python',
                      'def',
                      'solve',
                      '질문:',
                      '지키미:',
                      '답변:',
                      'print'
                    ];
                    
                    bool shouldSkip = false;
                    
                    // 코드 블록이 포함된 경우 정상적인 대화 부분만 추출
                    if (newText.contains('```')) {
                      // 코드 블록 시작 전까지의 텍스트만 추출
                      final codeBlockIndex = newText.indexOf('```');
                      if (codeBlockIndex > 0) {
                        final cleanText = newText.substring(0, codeBlockIndex).trim();
                        if (cleanText.isNotEmpty) {
                          print('자동 이어쓰기에서 코드 블록 감지, 정상 대화 부분만 전송: "$cleanText"');
                          yield cleanText;
                          return; // 코드 블록이 있으면 여기서 종료
                        }
                      }
                      print('자동 이어쓰기에서 코드 블록 감지: "$newText" - 스킵');
                      shouldSkip = true;
                    } else {
                      // 다른 금지 단어들 체크
                      for (final word in forbiddenWords) {
                        if (word != '```' && newText.contains(word)) {
                          print('자동 이어쓰기에서 불필요한 패턴 감지: "$newText" - 매칭된 단어: "$word"');
                          shouldSkip = true;
                          break;
                        }
                      }
                    }
                    
                    if (shouldSkip) {
                      print('자동 이어쓰기에서 불필요한 패턴 감지: "$newText" - 스킵');
                      consecutiveSkips++;
                      if (consecutiveSkips >= maxConsecutiveSkips) {
                        print('자동 이어쓰기에서 연속 스킵 한도 초과 ($consecutiveSkips회) - 생성 중단');
                        malloc.free(outBuf);
                        malloc.free(genPtr);
                        return;
                      }
                      continue;
                    }
                    
                    // 유효한 텍스트가 나오면 스킵 카운터 리셋
                    consecutiveSkips = 0;
                    
                    // 반복 패턴 감지 (자동 이어쓰기)
                    final words = newText.trim().split(RegExp(r'\s+'));
                    for (final word in words) {
                      if (word.isNotEmpty) {
                        recentTokens.add(word);
                        if (recentTokens.length > maxRecentTokens) {
                          recentTokens.removeAt(0);
                        }
                        
                        // 반복 패턴 체크
                        if (recentTokens.length >= 4) {
                          final lastFour = recentTokens.sublist(recentTokens.length - 4);
                          final pattern = lastFour.join(' ');
                          int patternCount = 0;
                          
                          for (int i = 0; i <= recentTokens.length - 4; i++) {
                            final checkPattern = recentTokens.sublist(i, i + 4).join(' ');
                            if (checkPattern == pattern) {
                              patternCount++;
                            }
                          }
                          
                          if (patternCount >= maxRepetitionThreshold) {
                            print('자동 이어쓰기에서 반복 패턴 감지: "$pattern" (${patternCount}회) - 생성 중단');
                            malloc.free(outBuf);
                            malloc.free(genPtr);
                            return;
                          }
                        }
                      }
                    }
                    
                    print('자동 이어쓰기 전송: "$newText"');
                    yield newText;
                    lastYieldedLength = currentText.length;
                  }
                }
                malloc.free(outBuf);
                malloc.free(genPtr);
              }
              
              // UI가 블록되지 않도록 더 자주 yield
              await Future.delayed(const Duration(milliseconds: 10));
            }
            print('자동 이어쓰기 완료 - 최종 토큰: $steps');
          }

          // 최종 텍스트 전송 (남은 부분이 있다면)
          if (currentText.length > lastYieldedLength) {
            final finalText = currentText.substring(lastYieldedLength);
            yield finalText;
          }
        } else {
          yield 'llama_decode 실패 (코드: $lastDecodeResult)';
        }
        
        print('AI 추론 완료');
      } catch (e) {
        print('AI 추론 중 오류: $e');
        yield '죄송합니다. AI 추론 중 오류가 발생했습니다: $e';
      }
      
      // 메모리 해제
      malloc.free(promptPtr);
      malloc.free(tokens);
      
    } catch (e) {
      print('텍스트 생성 실패: $e');
      yield '텍스트 생성 중 오류가 발생했습니다: $e';
    }
  }

  /// 텍스트 생성 (greedy decoding) - 기존 메서드 유지
  Future<String> generateText(String prompt, {int maxTokens = 512, int minTokensBeforeEog = 32, bool autoContinue = true, int maxTotalTokens = 2048, bool respectShortAnswers = true}) async {
    if (!_isInitialized || _model == null || _context == null) {
      return 'FFI가 초기화되지 않았거나 모델이 로드되지 않았습니다';
    }
    
    try {
      // vocab 가져오기
      final vocab = _llamaModelGetVocab(_model!);
      if (vocab == nullptr) {
        return 'vocab을 가져올 수 없습니다';
      }
      
      // 프롬프트 토큰화
      final promptPtr = prompt.toNativeUtf8();
      final tokens = malloc<Int32>(512); // 최대 512 토큰
      
      final textLenBytes = utf8.encode(prompt).length;
      final tokenCount = _llamaTokenize(
        vocab,
        promptPtr,
        textLenBytes,
        tokens,
        512,
        true, // add_bos
        false, // special
      );
      
      if (tokenCount < 0) {
        malloc.free(promptPtr);
        malloc.free(tokens);
        return '토큰화 실패';
      }
      
      // 실제 AI 추론 시도 (llama_batch_get_one 사용 - 더 안전한 방법)
      String response;
      try {
        print('실제 AI 추론 시작 - llama_batch_get_one 사용');
        
        // 1. 안전한 토큰 처리 (메모리 오류 방지)
        print('안전한 토큰 처리 시작 (토큰 수: $tokenCount)');
        
        // 4. 안전한 토큰 처리 (메모리 오류 방지)
        bool allTokensProcessed = true;
        int lastDecodeResult = 0;
        int minEog = minTokensBeforeEog;
        bool autoCont = autoContinue;
        if (respectShortAnswers) {
          minEog = 0;
          autoCont = false;
        }
        
        // 프롬프트 배치: helper 사용 (llama_batch_get_one)
        print('프롬프트 배치 구성 시작 (ubatch get_one)...');
        const int chunkSize = 32; // 작은 단위로 나눠 디코드하여 KV 슬롯 문제 회피
        int processed = 0;
        allTokensProcessed = true;
        while (processed < tokenCount) {
          final remain = tokenCount - processed;
          final cur = remain < chunkSize ? remain : chunkSize;
          final chunkPtr = malloc<Int32>(cur);
          for (int i = 0; i < cur; i++) {
            chunkPtr[i] = tokens[processed + i];
          }
          final batch = _llamaBatchGetOne(chunkPtr, cur);
          if (batch.logits != nullptr) {
            for (int i = 0; i < cur; i++) {
              batch.logits[i] = (i == cur - 1) ? 1 : 0;
            }
          }
          print('llama_decode 호출 시작 (프롬프트 ubatch: $processed~${processed + cur - 1})');
          final dr = _llamaDecode(_context!, batch);
          malloc.free(chunkPtr);
          print('llama_decode 결과: $dr');
          if (dr != 0) {
            allTokensProcessed = false;
            lastDecodeResult = dr;
            break;
          }
          processed += cur;
        }
        
        print('모든 토큰 처리 시뮬레이션 완료');

        if (allTokensProcessed) {
          final vocab = _llamaModelGetVocab(_model!);
          final generated = <int>[];
          int steps = 0;
          // 컨텍스트 크기에 맞춰 총 생성 한도 계산 (여유 margin 보유)
          final ctxSize = _llamaNCtx(_context!);
          final margin = 16;
          final promptTokens = tokenCount;
          final maxByCtx = ctxSize - promptTokens - margin;
          final hardTotalCap = maxByCtx > 0 ? maxByCtx : maxTotalTokens;

          // 내부 함수: 한 스텝 생성
          Future<bool> generateOneStep({required bool ignoreEog}) async {
            final logitsPtr = _llamaGetLogitsIth(_context!, -1);
            if (logitsPtr == nullptr) {
              return false;
            }

            final nVocab = _llamaVocabNTokens(vocab);
            int bestId = -1;
            double bestLogit = -double.maxFinite;
            int secondId = -1;
            double secondLogit = -double.maxFinite;
            for (int i = 0; i < nVocab; i++) {
              final v = logitsPtr.elementAt(i).value.toDouble();
              if (v > bestLogit) {
                secondLogit = bestLogit; secondId = bestId;
                bestLogit = v; bestId = i;
              } else if (v > secondLogit) {
                secondLogit = v; secondId = i;
              }
            }

            // 너무 이른 EOG 방지: 초기 N토큰 동안은 EOG를 무시하고 차선 토큰 사용
            if (steps < minEog && bestId != -1 && _llamaVocabIsEog(vocab, bestId) != 0) {
              if (secondId != -1) {
                bestId = secondId;
              }
            }

            // EOG 처리: auto-continue 구간에서는 차선 토큰으로 대체 시도
            if (bestId != -1 && _llamaVocabIsEog(vocab, bestId) != 0) {
              if (ignoreEog && secondId != -1) {
                bestId = secondId;
              } else {
                return false;
              }
            }

            generated.add(bestId);

            final oneToken = malloc<Int32>(1);
            oneToken[0] = bestId;
            final stepBatch = _llamaBatchGetOne(oneToken, 1);
            if (stepBatch.logits != nullptr) {
              stepBatch.logits[0] = 1;
            }
            final r = _llamaDecode(_context!, stepBatch);
            malloc.free(oneToken);
            if (r != 0) {
              return false;
            }
            steps++;
            
            // UI가 블록되지 않도록 주기적으로 yield
            if (steps % 3 == 0) {
              await Future.delayed(const Duration(milliseconds: 1));
            }
            
            return true;
          }

          // 1차 루프: maxTokens까지 생성
          while (steps < maxTokens && steps < hardTotalCap) {
            if (!(await generateOneStep(ignoreEog: false))) break;
          }

          // 자동 이어쓰기: EOG가 아니고 총 토큰 한도 내면 계속
          if (autoCont) {
            while (steps < maxTotalTokens && steps < hardTotalCap) {
              if (!(await generateOneStep(ignoreEog: true))) break;
            }
          }

          // detokenize로 UTF-8 문자열 생성 (동적 버퍼 크기)
          String detok = '';
          if (generated.isNotEmpty) {
            final genPtr = malloc<Int32>(generated.length);
            for (int i = 0; i < generated.length; i++) {
              genPtr[i] = generated[i];
            }
            int cap = 8192;
            Pointer<Uint8> outBuf = malloc<Uint8>(cap);
            int wrote = _llamaDetokenize(
              vocab,
              genPtr,
              generated.length,
              outBuf.cast<Utf8>(),
              cap,
              1, // remove_special
              1, // unparse_special
            );
            if (wrote < 0) {
              // 필요한 크기만큼 재할당 후 재시도
              malloc.free(outBuf);
              cap = -wrote + 4;
              outBuf = malloc<Uint8>(cap);
              wrote = _llamaDetokenize(
                vocab,
                genPtr,
                generated.length,
                outBuf.cast<Utf8>(),
                cap,
                1,
                1,
              );
            }
            if (wrote > 0) {
              final bytes = outBuf.asTypedList(wrote);
              detok = utf8.decode(bytes, allowMalformed: true);
            }
            malloc.free(outBuf);
            malloc.free(genPtr);
          }
          response = detok.trim();
        } else {
          response = 'llama_decode 실패 (코드: $lastDecodeResult)';
        }
        
        print('AI 추론 완료: $response');
      } catch (e) {
        print('AI 추론 중 오류: $e');
        response = '죄송합니다. AI 추론 중 오류가 발생했습니다: $e';
      }
      
      // 메모리 해제
      malloc.free(promptPtr);
      malloc.free(tokens);
      
      return response;
    } catch (e) {
      print('텍스트 생성 실패: $e');
      return '텍스트 생성 중 오류가 발생했습니다: $e';
    }
  }
  
  /// 모델 정보 조회
  Future<String> getModelInfo() async {
    if (!_isInitialized) return 'FFI가 초기화되지 않았습니다';
    if (_model == null) return '모델이 로드되지 않았습니다';
    
    try {
      // 모델 설명 가져오기
      final buffer = malloc<Uint8>(1024);
      final result = _llamaModelDesc(_model!, buffer.cast<Utf8>(), 1024);
      
      String modelDesc = 'llama.cpp 모델 로드됨';
      if (result > 0) {
        modelDesc = buffer.cast<Utf8>().toDartString();
      }
      
      malloc.free(buffer);
      return modelDesc;
    } catch (e) {
      print('모델 정보 조회 실패: $e');
      return 'llama.cpp 모델이 성공적으로 로드되었습니다.';
    }
  }
  
  /// 내부 정리 함수
  void _cleanup() {
    if (_context != null) {
      _llamaFree(_context!);
      _context = null;
    }
    if (_model != null) {
      _llamaModelFree(_model!);
      _model = null;
    }
  }
  
  /// 리소스 정리
  void dispose() {
    if (!_isInitialized) return;
    
    try {
      _cleanup();
      _isInitialized = false;
      _lib = null;
      print('FFI 리소스 정리 완료');
    } catch (e) {
      print('FFI 리소스 정리 실패: $e');
    }
  }
  
  /// 현재 플랫폼 정보
  String get platformInfo {
    return '${Platform.operatingSystem} (${Platform.operatingSystemVersion})';
  }
  
  /// FFI 사용 가능 여부
  bool get isFFISupported {
    return _lib != null;
  }
}