import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/model/ai_message.dart';
import '../../../l10n/app_localizations.dart';

/// 채팅 메시지 버블 위젯
/// 
/// 사용자와 AI 메시지를 구분하여 표시하고,
/// 타임스탬프와 에러 상태를 처리합니다.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  final AIMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final isError = message.status == MessageStatus.error;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(theme, isUser),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _getBubbleColor(theme, isUser, isError),
                    borderRadius: _getBorderRadius(isUser),
                    border: isError
                        ? Border.all(
                            color: theme.colorScheme.error.withOpacity(0.5),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getTextColor(theme, isUser, isError),
                          fontWeight:
                              isUser ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      if (isError && onRetry != null) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: onRetry,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 16,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.retry,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _formatTimestamp(message.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(theme, isUser),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser
          ? theme.colorScheme.primary.withOpacity(0.2)
          : theme.colorScheme.secondary.withOpacity(0.2),
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        size: 16,
        color: isUser
            ? theme.colorScheme.primary
            : theme.colorScheme.secondary,
      ),
    );
  }

  Color _getBubbleColor(ThemeData theme, bool isUser, bool isError) {
    if (isError) {
      return theme.colorScheme.errorContainer.withOpacity(0.3);
    }
    
    if (isUser) {
      return theme.colorScheme.primary;
    }
    
    return theme.brightness == Brightness.light
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHigh;
  }

  Color _getTextColor(ThemeData theme, bool isUser, bool isError) {
    if (isError) {
      return theme.colorScheme.onErrorContainer;
    }
    
    if (isUser) {
      return theme.colorScheme.onPrimary;
    }
    
    return theme.colorScheme.onSurface;
  }

  BorderRadius _getBorderRadius(bool isUser) {
    return BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isUser ? 20 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 20),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final context = WidgetsBinding.instance.rootElement;
    if (context == null) {
      return DateFormat('HH:mm').format(timestamp);
    }
    
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return DateFormat('HH:mm').format(timestamp);
    }
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat('MM/dd HH:mm').format(timestamp);
    }
  }
}
