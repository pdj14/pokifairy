import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../shared/providers/ai_providers.dart';
import '../../shared/services/ai/model_manager.dart';
import '../../l10n/app_localizations.dart';

/// AI 모델 디버그 정보 화면
/// 
/// AI 초기화 상태, 모델 정보, FFI 연결 상태 등을 표시합니다.
class ModelDebugPage extends ConsumerWidget {
  const ModelDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aiInit = ref.watch(aiInitializationProvider);
    final modelInfo = ref.watch(aiModelInfoProvider);
    final currentModelPath = ref.watch(currentModelPathProvider);
    final debugInfo = ref.watch(aiDebugInfoProvider);
    final debugLogs = ref.watch(aiDebugLogsProvider);
    final engineStatus = ref.watch(aiEngineStatusProvider);
    final initTime = ref.watch(aiInitializationTimeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modelDebugTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(aiInitializationProvider);
              ref.invalidate(aiModelInfoProvider);
              ref.invalidate(currentModelPathProvider);
            },
            tooltip: l10n.debugRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(aiInitializationProvider);
          ref.invalidate(aiModelInfoProvider);
          ref.invalidate(currentModelPathProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI 초기화 상태 섹션
              _buildSectionCard(
                context,
                title: l10n.debugInitStatus,
                icon: Icons.power_settings_new,
                child: aiInit.when(
                  data: (isInitialized) => _buildInitializationStatus(
                    context,
                    isInitialized,
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => _buildErrorInfo(
                    context,
                    l10n.errorModelLoadFailed,
                    error.toString(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 현재 모델 정보 섹션
              _buildSectionCard(
                context,
                title: l10n.debugModelInfo,
                icon: Icons.memory,
                child: currentModelPath.when(
                  data: (path) => _buildCurrentModelInfo(
                    context,
                    path,
                    modelInfo,
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => _buildErrorInfo(
                    context,
                    l10n.errorModelLoadFailed,
                    error.toString(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // FFI 연결 상태 섹션
              _buildSectionCard(
                context,
                title: l10n.debugFFIStatus,
                icon: Icons.link,
                child: _buildFFIStatus(context, aiInit, modelInfo),
              ),
              const SizedBox(height: 16),

              // 시스템 정보 섹션
              _buildSectionCard(
                context,
                title: l10n.debugSystemInfo,
                icon: Icons.info_outline,
                child: _buildSystemInfo(context, initTime),
              ),
              const SizedBox(height: 16),

              // 추론 엔진 상태 섹션
              if (engineStatus != null)
                _buildSectionCard(
                  context,
                  title: l10n.debugEngineStatus,
                  icon: Icons.settings_applications,
                  child: _buildEngineStatus(context, engineStatus),
                ),
              const SizedBox(height: 16),

              // 디버그 로그 섹션
              _buildSectionCard(
                context,
                title: '${l10n.debugLogs} (${debugLogs.length})',
                icon: Icons.bug_report,
                child: _buildDebugLogs(context, debugLogs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 섹션 카드 빌더
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  /// AI 초기화 상태 표시
  Widget _buildInitializationStatus(
    BuildContext context,
    bool isInitialized,
  ) {
    return Column(
      children: [
        _buildStatusRow(
          context,
          '초기화 상태',
          isInitialized ? '성공' : '실패',
          isInitialized ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 8),
        _buildStatusRow(
          context,
          '서비스 상태',
          isInitialized ? '활성' : '비활성',
          isInitialized ? Colors.green : Colors.grey,
        ),
      ],
    );
  }

  /// 현재 모델 정보 표시
  Widget _buildCurrentModelInfo(
    BuildContext context,
    String? modelPath,
    Map<String, dynamic>? modelInfo,
  ) {
    if (modelPath == null) {
      return _buildInfoText(context, '선택된 모델이 없습니다');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          '모델 경로',
          modelPath,
          copyable: true,
        ),
        const SizedBox(height: 12),
        if (modelInfo != null) ...[
          _buildInfoRow(
            context,
            '유효성',
            modelInfo['isValid'] == true ? '유효' : '무효',
          ),
          const SizedBox(height: 8),
          if (modelInfo['architecture'] != null)
            _buildInfoRow(
              context,
              '아키텍처',
              modelInfo['architecture'].toString(),
            ),
          const SizedBox(height: 8),
          if (modelInfo['quantization'] != null)
            _buildInfoRow(
              context,
              '양자화',
              modelInfo['quantization'].toString(),
            ),
          const SizedBox(height: 8),
          if (modelInfo['fileSize'] != null)
            _buildInfoRow(
              context,
              '파일 크기',
              _formatBytes(modelInfo['fileSize'] as int),
            ),
          const SizedBox(height: 8),
          if (modelInfo['parameterCount'] != null)
            _buildInfoRow(
              context,
              '파라미터 수',
              modelInfo['parameterCount'].toString(),
            ),
          const SizedBox(height: 12),
          if (modelInfo['metadata'] != null) ...[
            Text(
              '메타데이터:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ..._buildMetadataList(context, modelInfo['metadata']),
          ],
        ] else
          _buildInfoText(context, '모델 정보를 불러올 수 없습니다'),
      ],
    );
  }

  /// FFI 연결 상태 표시
  Widget _buildFFIStatus(
    BuildContext context,
    AsyncValue<bool> aiInit,
    Map<String, dynamic>? modelInfo,
  ) {
    final isConnected = aiInit.value == true && modelInfo?['isValid'] == true;
    
    return Column(
      children: [
        _buildStatusRow(
          context,
          'FFI 바인딩',
          isConnected ? '연결됨' : '연결 안 됨',
          isConnected ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildStatusRow(
          context,
          '네이티브 엔진',
          isConnected ? '로드됨' : '로드 안 됨',
          isConnected ? Colors.green : Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          '플랫폼',
          _getPlatformName(),
        ),
      ],
    );
  }

  /// 시스템 정보 표시
  Widget _buildSystemInfo(BuildContext context, DateTime? initTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          '모델 디렉토리',
          ModelManager.getModelsDirectory(),
          copyable: true,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Flutter 버전',
          'Flutter SDK',
        ),
        const SizedBox(height: 8),
        if (initTime != null)
          _buildInfoRow(
            context,
            '초기화 시간',
            _formatDateTime(initTime),
          ),
      ],
    );
  }

  /// 추론 엔진 상태 표시
  Widget _buildEngineStatus(
    BuildContext context,
    Map<String, dynamic> status,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusRow(
          context,
          '엔진 로드 상태',
          status['isLoaded'] == true ? '로드됨' : '로드 안 됨',
          status['isLoaded'] == true ? Colors.green : Colors.grey,
        ),
        const SizedBox(height: 8),
        if (status['modelPath'] != null)
          _buildInfoRow(
            context,
            '엔진 모델 경로',
            status['modelPath'].toString(),
          ),
        const SizedBox(height: 8),
        if (status['platform'] != null)
          _buildInfoRow(
            context,
            '플랫폼 정보',
            status['platform'].toString(),
          ),
        const SizedBox(height: 8),
        if (status['ffiSupported'] != null)
          _buildStatusRow(
            context,
            'FFI 지원',
            status['ffiSupported'] == true ? '지원됨' : '지원 안 됨',
            status['ffiSupported'] == true ? Colors.green : Colors.red,
          ),
      ],
    );
  }

  /// 디버그 로그 표시
  Widget _buildDebugLogs(BuildContext context, List<String> logs) {
    if (logs.isEmpty) {
      return _buildInfoText(context, '로그가 없습니다');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[logs.length - 1 - index]; // 최신 로그가 위로
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Text(
                  log,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              final l10n = AppLocalizations.of(context)!;
              Clipboard.setData(ClipboardData(text: logs.join('\n')));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.logsCopied),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: Text(AppLocalizations.of(context)!.copyLogs),
          ),
        ),
      ],
    );
  }

  /// 상태 행 빌더
  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    Color statusColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  /// 정보 행 빌더
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool copyable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
              if (copyable)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    final l10n = AppLocalizations.of(context)!;
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.logsCopied),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 정보 텍스트 빌더
  Widget _buildInfoText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
    );
  }

  /// 에러 정보 빌더
  Widget _buildErrorInfo(
    BuildContext context,
    String title,
    String error,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  /// 메타데이터 리스트 빌더
  List<Widget> _buildMetadataList(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    return metadata.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _buildInfoRow(
          context,
          entry.key,
          entry.value.toString(),
        ),
      );
    }).toList();
  }

  /// 바이트를 읽기 쉬운 형식으로 변환
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// 플랫폼 이름 가져오기
  String _getPlatformName() {
    if (Theme.of(WidgetsBinding.instance.rootElement!).platform ==
        TargetPlatform.android) {
      return 'Android';
    } else if (Theme.of(WidgetsBinding.instance.rootElement!).platform ==
        TargetPlatform.iOS) {
      return 'iOS';
    }
    return 'Unknown';
  }

  /// 날짜/시간 포맷팅
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
