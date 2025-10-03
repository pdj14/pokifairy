import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/model/chat_message.dart';
import 'package:pokifairy/shared/providers/chat_providers.dart';
import 'package:pokifairy/shared/providers/fairy_providers.dart';
import 'package:pokifairy/shared/utils/color_utils.dart';

/// 요정과 채팅하는 화면
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;
  final _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider.notifier).addUserMessage(text);
    _textController.clear();

    // 메시지 전송 후 스크롤을 아래로
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
    final fairy = ref.watch(fairyProvider);
    final messages = ref.watch(chatProvider);
    final accentColor = fairy != null ? colorFromHex(fairy.color) : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatTitle),
        backgroundColor: accentColor.withOpacity(0.1),
      ),
      body: Column(
        children: [
          // 상단: 요정 이미지와 말풍선 영역
          _FairyDisplayArea(
            fairy: fairy,
            accentColor: accentColor,
            lastMessage: messages.isNotEmpty && !messages.last.isUser
                ? messages.last.text
                : null,
          ),
          
          const Divider(height: 1),
          
          // 중간: 채팅 메시지 리스트
          Expanded(
            child: messages.isEmpty
                ? _EmptyChatState(l10n: l10n)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _MessageBubble(
                        message: message,
                        accentColor: accentColor,
                      );
                    },
                  ),
          ),
          
          const Divider(height: 1),
          
          // 하단: 입력창
          _ChatInputArea(
            key: _textFieldKey,
            controller: _textController,
            onSend: _handleSendMessage,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
}

/// 요정 이미지와 말풍선 표시 영역
class _FairyDisplayArea extends StatelessWidget {
  const _FairyDisplayArea({
    required this.fairy,
    required this.accentColor,
    this.lastMessage,
  });

  final dynamic fairy;
  final Color accentColor;
  final String? lastMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withOpacity(0.15),
            accentColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // 요정 이미지
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: fairy != null
                  ? Image.asset(
                      'assets/images/PockiFairy.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 50,
                            color: accentColor,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 50,
                        color: accentColor,
                      ),
                    ),
            ),
          ),
          
          if (lastMessage != null) ...[
            const SizedBox(height: 16),
            // 말풍선
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                lastMessage!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.chatEmptyMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 메시지 버블
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.accentColor,
  });

  final ChatMessage message;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: accentColor.withOpacity(0.2),
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF5B9BD5)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontWeight: message.isUser ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 채팅 입력 영역
class _ChatInputArea extends StatefulWidget {
  const _ChatInputArea({
    super.key,
    required this.controller,
    required this.onSend,
    required this.accentColor,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final Color accentColor;

  @override
  State<_ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<_ChatInputArea> {
  final _inputKey = const ValueKey('chat_input_field');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: _inputKey,
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: l10n.chatInputHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => widget.onSend(),
                autofocus: false,
                enableIMEPersonalizedLearning: true,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B9BD5).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: widget.onSend,
                icon: const Icon(Icons.send, color: Colors.white),
                iconSize: 24,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
