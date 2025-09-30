import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokifairy/app/app_router.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/model/fairy.dart';
import 'package:pokifairy/shared/providers/fairy_providers.dart';
import 'package:pokifairy/shared/widgets/fairy_animation_card.dart';
import 'package:pokifairy/shared/widgets/fairy_selection_widget.dart';
import 'package:pokifairy/shared/widgets/primary_button.dart';

/// 온보딩 화면: 요정 생성 폼을 보여준다.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _selectedFairyIndex = 0; // 기본 선택을 0번(1번)으로 설정

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final controller = ref.read(fairyControllerProvider.notifier);
    final createdFairy = await controller.createFairy(
      name: _nameController.text,
      species: FairySpecies.spirit, // 기본 종족으로 설정
      color: '#FFFFFF',
      imageIndex: _selectedFairyIndex,
    );

    if (!mounted) return;

    if (createdFairy != null) {
      ref.read(careLogProvider.notifier).clear();
      context.go(AppRoute.landing.path);
    } else {
      final error = ref
          .read(fairyControllerProvider)
          .maybeWhen(error: (err, __) => err, orElse: () => null);
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fairy = ref.watch(fairyProvider);
    final l10n = AppLocalizations.of(context)!;

    if (fairy != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(AppRoute.landing.path);
        }
      });
    }

    final isLoading = ref.watch(fairyControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        '포켓 속의 요정을 만나볼까요? 요정을 선택하고 이름을 붙여주세요.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FairySelectionWidget(
                    selectedIndex: _selectedFairyIndex,
                    onSelectionChanged: (index) {
                      setState(() {
                        _selectedFairyIndex = index;
                      });
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.setupNameLabel,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    enabled: !isLoading,
                    maxLength: 12,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    enableSuggestions: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')), // 공백 제거
                    ],
                    decoration: InputDecoration(hintText: l10n.setupNameHint),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return l10n.setupValidationEmpty;
                      if (trimmed.length > 12) return l10n.setupValidationTooLong;
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: l10n.setupCreateButton,
                    tooltip: l10n.setupCreateButton,
                    semanticLabel: l10n.setupCreateButton,
                    onPressed: isLoading ? null : _submit,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
