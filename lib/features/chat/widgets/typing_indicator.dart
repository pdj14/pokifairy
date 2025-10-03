import 'package:flutter/material.dart';

/// 타이핑 인디케이터 위젯
/// 
/// AI가 응답을 생성하는 동안 표시되는 애니메이션입니다.
/// 세 개의 점이 순차적으로 깜빡이는 효과를 제공합니다.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI 아바타
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
          child: Icon(
            Icons.auto_awesome,
            size: 16,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        // 타이핑 버블
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(0, theme),
                  const SizedBox(width: 4),
                  _buildDot(1, theme),
                  const SizedBox(width: 4),
                  _buildDot(2, theme),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    // 각 점의 애니메이션 시작 시간을 다르게 설정
    final delay = index * 0.2;
    final value = (_controller.value - delay) % 1.0;
    
    // 0 -> 1 -> 0 사이클로 투명도 변화
    final opacity = value < 0.5
        ? (value * 2).clamp(0.3, 1.0)
        : ((1.0 - value) * 2).clamp(0.3, 1.0);
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.onSurface.withOpacity(opacity),
      ),
    );
  }
}
