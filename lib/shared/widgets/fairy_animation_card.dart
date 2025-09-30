import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

/// A card that displays a looping animation from a spritesheet image.
/// Assumes a uniform grid spritesheet of [columns] x [rows].
class FairyAnimationCard extends StatelessWidget {
  const FairyAnimationCard({
    super.key,
    required this.assetPath,
    this.columns = 4,
    this.rows = 4,
    this.fps = 4,
    this.size = const Size(140, 140),
    this.label,
  });

  final String assetPath;
  final int columns;
  final int rows;
  final double fps;
  final Size size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100,
              Colors.pink.shade100,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GameWidget<FairyAnimationGame>.controlled(
                    gameFactory: () => FairyAnimationGame(
                      assetPath: assetPath,
                      columns: columns,
                      rows: rows,
                      fps: fps,
                      containerSize: size,
                    ),
                  ),
                ),
              ),
              if (label != null) ...[
                const SizedBox(height: 8),
                Text(label!, style: Theme.of(context).textTheme.labelLarge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FairyAnimationGame extends FlameGame {
  FairyAnimationGame({
    required this.assetPath,
    required this.columns,
    required this.rows,
    required this.fps,
    required this.containerSize,
  });

  final String assetPath;
  final int columns;
  final int rows;
  final double fps;
  final Size containerSize;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    final image = await images.load(assetPath);
    final spriteSize = Vector2(
      image.width / columns,
      image.height / rows,
    );
    final sheet = SpriteSheet(image: image, srcSize: spriteSize);

    final frames = <SpriteAnimationFrame>[];
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        frames.add(SpriteAnimationFrame(sheet.getSprite(x, y), 1 / fps));
      }
    }
    
    final animation = SpriteAnimation(frames);
    final spriteAnimationComponent = SpriteAnimationComponent(
      animation: animation,
      size: spriteSize, // 원본 스프라이트 크기 유지
      position: Vector2(containerSize.width / 2, containerSize.height / 2), // 컨테이너 정중앙
      anchor: Anchor.center, // 앵커를 중앙으로 설정
    );
    
    add(spriteAnimationComponent);
  }
}


