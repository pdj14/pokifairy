import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokifairy/app/app_router.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/model/fairy.dart';
import 'package:pokifairy/shared/providers/fairy_providers.dart';
import 'package:pokifairy/shared/utils/color_utils.dart';
import 'package:pokifairy/shared/widgets/fairy_selection_widget.dart';
import 'package:pokifairy/shared/widgets/primary_button.dart';

/// 홈 화면: 요정이 있으면 보여주고, 없으면 만들기/삭제 옵션 제공
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairy = ref.watch(fairyProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: fairy == null
              ? _EmptyState(onCreate: () => context.push(AppRoute.onboarding.path))
              : _FairyDisplay(
                  fairy: fairy,
                  onDelete: () => _confirmDelete(context, ref),
                ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.landingDeleteDialogTitle),
        content: Text(l10n.landingDeleteDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.dialogButtonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(fairyControllerProvider.notifier).resetFairy();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.landingDeletedMessage)),
        );
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.landingEmptyTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.landingEmptyDescription,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: l10n.landingCreateButton,
            icon: const Icon(Icons.auto_awesome),
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

class _FairyDisplay extends ConsumerWidget {
  const _FairyDisplay({
    super.key,
    required this.fairy,
    required this.onDelete,
  });

  final Fairy fairy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = colorFromHex(fairy.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.homeTodayGreeting(fairy.name),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
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
                  accentColor.withOpacity(0.3),
                  accentColor.withOpacity(0.1),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 요정 이미지 표시
                Container(
                  width: 120,
                  height: 120,
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
                    child: Image.asset(
                      'assets/images/character/fairy${fairy.imageIndex + 1}.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showEditNameDialog(context, ref, fairy.name),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fairy.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: accentColor.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.homeLevelLabel(fairy.level),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                // 상태 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatIndicator(
                      icon: Icons.mood,
                      label: '기분',
                      value: fairy.mood,
                      color: Colors.pink,
                    ),
                    _StatIndicator(
                      icon: Icons.restaurant,
                      label: '배고픔',
                      value: 100 - fairy.hunger,
                      color: Colors.orange,
                    ),
                    _StatIndicator(
                      icon: Icons.battery_charging_full,
                      label: '에너지',
                      value: fairy.energy,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('요정 삭제'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final l10n = AppLocalizations.of(context)!;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('요정 이름 변경'),
        content: TextField(
          controller: controller,
          maxLength: 12,
          textCapitalization: TextCapitalization.none,
          keyboardType: TextInputType.text,
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')), // 공백 제거
          ],
          decoration: const InputDecoration(
            hintText: '새로운 이름을 입력하세요',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogButtonCancel),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName.length <= 12) {
                Navigator.of(context).pop(newName);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result != null && result != currentName) {
      await ref.read(fairyControllerProvider.notifier).updateFairyName(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('요정 이름이 변경되었습니다')),
        );
      }
    }
  }
}

class _StatIndicator extends StatelessWidget {
  const _StatIndicator({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          '$value%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}