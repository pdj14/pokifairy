import 'package:flutter/material.dart';
import 'package:pokifairy/shared/widgets/fairy_animation_card.dart';

/// 요정 선택 화면
class FairySelectionWidget extends StatefulWidget {
  const FairySelectionWidget({
    super.key,
    required this.selectedIndex,
    required this.onSelectionChanged,
    this.enabled = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;
  final bool enabled;

  @override
  State<FairySelectionWidget> createState() => _FairySelectionWidgetState();
}

class _FairySelectionWidgetState extends State<FairySelectionWidget> {
  bool _showTalkAnimation = true; // 항상 애니메이션 표시

  static const List<String> fairyAssets = [
    'character/fairy1.png',
    'character/fairy2.png',
    // 'character/fairy3.png',
    // 'character/fairy4.png',
    // 'character/fairy5.png',
    // 'character/fairy6.png',
    // 'character/fairy7.png',
    // 'character/fairy8.png',
  ];

  static const Map<int, String> _talkAssetByIndex = {
    0: 'character/talk/fairy1_talk.png',
    1: 'character/talk/fairy2_talk.png',
  };

  static const int _talkSheetColumns = 4;
  static const int _talkSheetRows = 4;

  void _handleFairySelection(int index) {
    widget.onSelectionChanged(index);
    // 애니메이션은 항상 표시되므로 별도 처리 불필요
  }

  @override
  Widget build(BuildContext context) {
    final talkAsset = _talkAssetByIndex[widget.selectedIndex];
    final shouldShowTalkAnimation = _showTalkAnimation && talkAsset != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '요정 선택',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // 항상 애니메이션 표시 (선택된 요정이 있는 경우)
        if (shouldShowTalkAnimation)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: FairyAnimationCard(
                key: ValueKey('fairy_animation_${widget.selectedIndex}'),
                assetPath: talkAsset!,
                columns: _talkSheetColumns,
                rows: _talkSheetRows,
                fps: 4,
                size: const Size(200, 150),
              ),
            ),
          ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: fairyAssets.length,
          itemBuilder: (context, index) {
            final isSelected = widget.selectedIndex == index;
            return GestureDetector(
              onTap: widget.enabled ? () => _handleFairySelection(index) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey.shade50,
                ),
                child: Stack(
                  children: [
                    // 요정 이미지吏
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset(
                        'assets/images/${fairyAssets[index]}',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    // 선택 표시
                    if (isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    // 번호 표시
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
