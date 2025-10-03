/// AI 모델 정보 모델
class AIModelInfo {
  final String name;
  final String path;
  final int sizeBytes;
  final String architecture;
  final bool isValid;
  final Map<String, dynamic>? metadata;

  AIModelInfo({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.architecture,
    required this.isValid,
    this.metadata,
  });

  /// 파일 크기를 읽기 쉬운 형식으로 변환
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(2)} KB';
    } else if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// 모델 복사 (불변성 유지)
  AIModelInfo copyWith({
    String? name,
    String? path,
    int? sizeBytes,
    String? architecture,
    bool? isValid,
    Map<String, dynamic>? metadata,
  }) {
    return AIModelInfo(
      name: name ?? this.name,
      path: path ?? this.path,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      architecture: architecture ?? this.architecture,
      isValid: isValid ?? this.isValid,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'sizeBytes': sizeBytes,
      'architecture': architecture,
      'isValid': isValid,
      'metadata': metadata,
    };
  }

  /// JSON 역직렬화
  factory AIModelInfo.fromJson(Map<String, dynamic> json) {
    return AIModelInfo(
      name: json['name'] as String,
      path: json['path'] as String,
      sizeBytes: json['sizeBytes'] as int,
      architecture: json['architecture'] as String,
      isValid: json['isValid'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'AIModelInfo(name: $name, path: $path, size: $formattedSize, architecture: $architecture, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AIModelInfo &&
        other.name == name &&
        other.path == path &&
        other.sizeBytes == sizeBytes &&
        other.architecture == architecture &&
        other.isValid == isValid;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      path,
      sizeBytes,
      architecture,
      isValid,
    );
  }
}
