// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '포키페어리';

  @override
  String get gateLoading => '요정을 데려오는 중...';

  @override
  String get gateError => '요정을 불러오지 못했어요.';

  @override
  String get retryButton => '다시 시도';

  @override
  String get setupTitle => '요정 이름 짓기';

  @override
  String get setupDescription => '당신의 요정에게 이름을 붙여 주세요.';

  @override
  String get setupNameLabel => '요정 이름';

  @override
  String get setupNameHint => '예: 루미';

  @override
  String get setupValidationEmpty => '이름을 입력해 주세요.';

  @override
  String get setupValidationTooLong => '이름은 12자 이하로 입력해 주세요.';

  @override
  String get setupCreateButton => '요정 만들기';

  @override
  String get speciesSpirit => '정령';

  @override
  String get speciesElf => '엘프';

  @override
  String get speciesHumanlike => '휴먼형';

  @override
  String homeGreeting(String name) {
    return '안녕, $name!';
  }

  @override
  String homeTodayGreeting(String name) {
    return '$name와 함께해요';
  }

  @override
  String homeLevelLabel(int level) {
    return '레벨 $level';
  }

  @override
  String get homeActionSectionTitle => '요정과 교감하기';

  @override
  String get homeActionPrompt => '요정과 어떤 놀이를 할까요?';

  @override
  String homeAffectionLabel(int count) {
    return '친밀도: $count';
  }

  @override
  String homeLastInteraction(String timestamp) {
    return '마지막 교감: $timestamp';
  }

  @override
  String get homeLastInteractionNever => '아직 교감 기록이 없어요.';

  @override
  String get homeResetTooltip => '요정 리셋';

  @override
  String get homeQuickLinksTitle => '빠른 이동';

  @override
  String get actionFeed => '간식 주기';

  @override
  String get actionPlay => '놀아주기';

  @override
  String get actionRest => '재우기';

  @override
  String get dialogActionResultTitle => '요정의 반응';

  @override
  String dialogActionResultMessageFeed(String name) {
    return '$name가 간식을 맛있게 먹었어요!';
  }

  @override
  String dialogActionResultMessagePlay(String name) {
    return '$name가 신나게 놀았어요!';
  }

  @override
  String dialogActionResultMessageRest(String name) {
    return '$name가 포근한 휴식을 취했어요.';
  }

  @override
  String get dialogButtonOk => '확인';

  @override
  String get dialogButtonCancel => '취소';

  @override
  String get statCardTitle => '요정 상태';

  @override
  String get statMoodLabel => '기분';

  @override
  String get statHungerLabel => '배고픔';

  @override
  String get statEnergyLabel => '에너지';

  @override
  String statExpLabel(int current, int goal) {
    return '경험치 $current/$goal';
  }

  @override
  String statLastTickLabel(String timestamp) {
    return '마지막 갱신: $timestamp';
  }

  @override
  String get landingEmptyTitle => '아직 요정을 만들지 않았어요';

  @override
  String get landingEmptyDescription => '먼저 요정을 만들어 포근한 친구를 맞이해 보세요.';

  @override
  String get landingCreateButton => '요정 만들러 가기';

  @override
  String get landingExistingTitle => '나의 요정';

  @override
  String get landingOpenButton => '요정과 놀러 가기';

  @override
  String get landingDeleteButton => '요정 삭제';

  @override
  String get landingDeleteDialogTitle => '요정을 초기화할까요?';

  @override
  String get landingDeleteDialogMessage => '초기화하면 요정의 모든 성장 기록이 사라집니다.';

  @override
  String get landingDeletedMessage => '요정을 떠나보냈어요. 새로운 친구를 다시 맞이해 주세요.';
}
