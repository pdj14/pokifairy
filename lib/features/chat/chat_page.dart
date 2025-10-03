import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/features/chat/providers/chat_providers.dart';
import 'package:pokifairy/features/chat/widgets/message_bubble.dart';
import 'package:pokifairy/features/chat/widgets/chat_input.dart';
import 'package:pokifairy/features/chat/widgets/typing_indicator.dart';
import 'package:pokifairy/features/chat/widgets/ai_loading_indicator.dart';
import 'package:pokifairy/shared/model/ai_message.dart';
import 'package:pokifairy/shared/providers/ai_providers.dart';
import 'package:pokifairy/shared/providers/fairy_providers.dart';
import 'package:pokifairy/app/app_router.dart';

/// AI와 채팅하는 화면
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 메시지 전송
    await ref.read(chatControllerProvider.notifier).sendMessage(text);

    // 메시지 전송 후 스크롤을 아래로
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = ref.watch(chatControllerProvider);
    final loadingProgress = ref.watch(aiLoadingProgressProvider);
    final theme = Theme.of(context);
    
    // AI 모델 정보 확인
    final currentModelAsync = ref.watch(currentModelInfoProvider);
    final aiService = ref.watch(aiServiceProvider);
    
    // 요정 정보 가져오기
    final fairy = ref.watch(fairyProvider);

    // 메시지가 추가될 때마다 스크롤
    ref.listen(chatControllerProvider, (previous, next) {
      if (next.length > (previous?.length ?? 0)) {
        _scrollToBottom();
      }
    });

    // AI가 응답 중인지 확인
    final isAiResponding = messages.isNotEmpty && 
        messages.last.status == MessageStatus.sending &&
        !messages.last.isUser;
    
    // AI 모델 로딩 중인지 확인
    final isAiLoading = loadingProgress.progress > 0.0 && !loadingProgress.isComplete;

    return Scaffold(
      appBar: AppBar(
        title: Text(fairy?.name ?? l10n.chatTitle),
        actions: [
          // 모델 변경 버튼
          IconButton(
            icon: const Icon(Icons.settings_suggest),
            tooltip: 'Change AI Model',
            onPressed: () {
              context.push(AppRoute.modelSelection.path);
            },
          ),
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.clearHistory),
                    content: Text(l10n.clearHistoryConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.clear),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  await ref.read(chatControllerProvider.notifier).clearHistory();
                }
              },
              tooltip: l10n.clearHistory,
            ),
        ],
      ),
      body: currentModelAsync.when(
        data: (currentModel) {
          // 모델이 선택되지 않은 경우만 "모델 없음" 표시
          if (currentModel == null) {
            return _NoModelState(l10n: l10n);
          }
          
          // 모델은 선택되어 있지만 AI 서비스가 초기화되지 않은 경우
          // (Lazy loading: 첫 메시지 전송 시 초기화됨)
          
          // 정상 채팅 UI
          return Column(
            children: [
              // AI 로딩 진행률 표시
              if (isAiLoading) const AiLoadingIndicator(),
              
              // 채팅 메시지 리스트
              Expanded(
                child: messages.isEmpty
                    ? _EmptyChatState(l10n: l10n)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length + (isAiResponding ? 1 : 0),
                        itemBuilder: (context, index) {
                          // 타이핑 인디케이터 표시
                          if (index == messages.length && isAiResponding) {
                            return const Padding(
                              key: ValueKey('typing_indicator'),
                              padding: EdgeInsets.only(bottom: 12),
                              child: TypingIndicator(),
                            );
                          }
                          
                          final message = messages[index];
                          return RepaintBoundary(
                            key: ValueKey('repaint_${message.id}'),
                            child: MessageBubble(
                              key: ValueKey(message.id),
                              message: message,
                              onRetry: message.status == MessageStatus.error
                                  ? () => ref.read(chatControllerProvider.notifier)
                                      .retryMessage(message.id)
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
              
              const Divider(height: 1),
              
              // 입력창
              ChatInput(
                onSend: _handleSendMessage,
                enabled: !isAiResponding && !isAiLoading,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _NoModelState(l10n: l10n),
      ),
    );
  }
}

/// 빈 채팅 상태
class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.chatEmptyMessage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chatEmptyHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 모델 없음 상태
class _NoModelState extends StatelessWidget {
  const _NoModelState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noModelTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noModelDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.go(AppRoute.modelSelection.path);
              },
              icon: const Icon(Icons.download),
              label: Text(l10n.goToModelSelection),
            ),
          ],
        ),
      ),
    );
  }
}
