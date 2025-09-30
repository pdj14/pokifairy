import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokifairy/app/app_router.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/providers/fairy_providers.dart';
import 'package:pokifairy/shared/widgets/primary_button.dart';
import 'package:pokifairy/shared/widgets/safe_lottie.dart';

/// 앱 첫 진입 시 요정 존재 여부에 따라 분기하는 랜딩 페이지.
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairy = ref.watch(fairyProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: fairy == null
              ? _EmptyState(onCreate: () => context.push(AppRoute.onboarding.path))
              : _ExistingState(onOpen: () => context.push(AppRoute.home.path)),
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
  const _ExistingState({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fairy = ref.watch(fairyProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.landingExistingTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (fairy != null)
                  ListTile(
                    leading: const Icon(Icons.auto_awesome),
                    title: Text(fairy.name),
                    subtitle: Text(l10n.homeLevelLabel(fairy.level)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.landingOpenButton,
          tooltip: l10n.landingOpenButton,
          semanticLabel: l10n.landingOpenButton,
          icon: const Icon(Icons.play_circle_fill),
          onPressed: onOpen,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: l10n.landingDeleteButton,
          tooltip: l10n.landingDeleteButton,
          semanticLabel: l10n.landingDeleteButton,
          icon: const Icon(Icons.delete_forever),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: Text(l10n.landingDeleteDialogTitle),
                  content: Text(l10n.landingDeleteDialogMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(l10n.dialogButtonCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(l10n.dialogButtonOk),
                    ),
                  ],
                );
              },
            );

            if (confirmed == true) {
              await ref.read(fairyControllerProvider.notifier).resetFairy();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l10n.landingDeletedMessage)));
              }
            }
          },
        ),
      ],
    );
  }
}


