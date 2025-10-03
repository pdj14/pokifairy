import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokifairy/app/app_router.dart';
import 'package:pokifairy/l10n/app_localizations.dart';

/// 설정 화면
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, l10n.settingsAiSection),
          ListTile(
            leading: const Icon(Icons.model_training),
            title: Text(l10n.settingsModelSelection),
            subtitle: Text(l10n.settingsModelSelectionDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoute.modelSelection.path),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: Text(l10n.settingsModelDebug),
            subtitle: Text(l10n.settingsModelDebugDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoute.modelDebug.path),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.settingsAboutSection),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAbout),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 PokiFairy',
      children: [
        const SizedBox(height: 16),
        Text(l10n.settingsAboutDescription),
      ],
    );
  }
}
