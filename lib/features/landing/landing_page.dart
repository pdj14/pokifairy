import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokifairy/app/app_router.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/model/fairy.dart';
import 'package:pokifairy/shared/providers/fairy_providers.dart';
import 'package:pokifairy/shared/widgets/primary_button.dart';
import 'package:pokifairy/shared/widgets/safe_lottie.dart';

/// 앱 첫 진입 시 요정 존재 여부에 따라 분기하는 랜딩 페이지.
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairy = ref.watch(fairyProvider);
    final fairiesList = ref.watch(fairiesListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: fairiesList.when(
            data: (fairies) => fairies.isEmpty
                ? _EmptyState(onCreate: () => context.go(AppRoute.onboarding.path))
                : _ExistingState(
                    fairies: fairies,
                    activeFairy: fairy,
                    onOpen: () => context.go(AppRoute.chat.path),
                    onCreate: () => context.go(AppRoute.onboarding.path),
                    onSwitchFairy: (fairyId) => ref.read(fairyControllerProvider.notifier).switchToFairy(fairyId),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: SafeLottie(
                  asset: 'assets/lottie/placeholder.json',
                  fallback: const Icon(Icons.auto_awesome, size: 120, color: Color(0xFFBDE0FE)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.landingEmptyTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.landingEmptyDescription,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        PrimaryButton(
          label: l10n.landingCreateButton,
          tooltip: l10n.landingCreateButton,
          semanticLabel: l10n.landingCreateButton,
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onCreate,
        ),
      ],
    );
  }
}

class _ExistingState extends ConsumerWidget {
  const _ExistingState({
    required this.fairies,
    required this.activeFairy,
    required this.onOpen,
    required this.onCreate,
    required this.onSwitchFairy,
  });

  final List<Fairy> fairies;
  final Fairy? activeFairy;
  final VoidCallback onOpen;
  final VoidCallback onCreate;
  final Function(String) onSwitchFairy;

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Fairy fairy) {
    final isActiveFairy = activeFairy?.id == fairy.id;
    
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('요정 삭제'),
          content: Text(
            isActiveFairy 
              ? '${fairy.name}은(는) 현재 선택된 요정입니다. 삭제하시겠습니까?\n삭제 후 다른 요정이 자동으로 선택됩니다.\n이 작업은 되돌릴 수 없습니다.'
              : '${fairy.name}을(를) 정말로 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteFairy(context, ref, fairy);
      }
    });
  }

  void _deleteFairy(BuildContext context, WidgetRef ref, Fairy fairy) async {
    try {
      final wasActiveFairy = activeFairy?.id == fairy.id;
      
      await ref.read(fairyControllerProvider.notifier).deleteFairy(fairy.id);
      
      // Provider들을 강제로 갱신
      ref.invalidate(allFairiesProvider);
      ref.invalidate(fairiesListProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${fairy.name}이(가) 삭제되었습니다.')),
        );
        
        // 삭제 후 잠시 기다린 후 상태 확인
        await Future.delayed(const Duration(milliseconds: 100));
        
        // 모든 요정이 삭제되었는지 확인
        final remainingFairies = await ref.read(fairiesListProvider.future);
        if (remainingFairies.isEmpty && context.mounted) {
          // 요정이 없으면 빈 상태 페이지로 이동
          context.go(AppRoute.landing.path);
        } else if (wasActiveFairy && context.mounted) {
          // 활성 요정을 삭제했고 다른 요정이 있다면 첫 번째 요정으로 전환
          final firstFairy = remainingFairies.first;
          await ref.read(fairyControllerProvider.notifier).switchToFairy(firstFairy.id);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${firstFairy.name}이(가) 선택되었습니다.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 현재 활성 요정 카드
        if (activeFairy != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목과 우측 요정 이미지를 포함한 헤더
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '현재 요정',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      // 우측 끝에 요정 이미지 표시
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/character/fairy${activeFairy!.imageIndex + 1}.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.auto_awesome),
                    title: Text(activeFairy!.name),
                    subtitle: Text(l10n.homeLevelLabel(activeFairy!.level)),
                  ),
                ],
              ),
            ),
          ),
        
        if (activeFairy != null) const SizedBox(height: 16),
        
        // 요정 친구들 목록
        Text(
          '요정 친구들',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fairies.length,
            itemBuilder: (context, index) {
              final fairy = fairies[index];
              final isActive = activeFairy?.id == fairy.id;
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isActive ? null : () => onSwitchFairy(fairy.id),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: isActive ? 2 : 1,
                          ),
                          color: isActive
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Colors.grey.shade50,
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/character/fairy${fairy.imageIndex + 1}.png',
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // 삭제 버튼을 여기로 이동 (모든 요정에 표시)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _showDeleteDialog(context, ref, fairy),
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.red.shade300, width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 10,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fairy.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.landingOpenButton,
          tooltip: l10n.landingOpenButton,
          semanticLabel: l10n.landingOpenButton,
          icon: const Icon(Icons.chat_bubble),
          onPressed: () => context.push(AppRoute.chat.path),
        ),
        const SizedBox(height: 12),
        // 테스트용 임시 버튼
        ElevatedButton(
          onPressed: () {
            print('새 요정 만들기 버튼 클릭됨');
            onCreate();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline),
              const SizedBox(width: 8),
              Text(l10n.landingCreateButton),
            ],
          ),
        ),
      ],
    );
  }
}


