import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// 앱의 기본 제목
  ///
  /// In ko, this message translates to:
  /// **'포키페어리'**
  String get appTitle;

  /// 게이트 화면 로딩 메시지
  ///
  /// In ko, this message translates to:
  /// **'요정을 데려오는 중...'**
  String get gateLoading;

  /// 게이트 화면 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'요정을 불러오지 못했어요.'**
  String get gateError;

  /// 재시도 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retryButton;

  /// 요정 생성 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'요정 이름 짓기'**
  String get setupTitle;

  /// 요정 생성 화면 설명
  ///
  /// In ko, this message translates to:
  /// **'당신의 요정에게 이름을 붙여 주세요.'**
  String get setupDescription;

  /// 요정 이름 입력 라벨
  ///
  /// In ko, this message translates to:
  /// **'요정 이름'**
  String get setupNameLabel;

  /// 요정 이름 입력 힌트
  ///
  /// In ko, this message translates to:
  /// **'예: 루미'**
  String get setupNameHint;

  /// 폼 검증 메시지
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력해 주세요.'**
  String get setupValidationEmpty;

  /// 이름 길이 검증 메시지
  ///
  /// In ko, this message translates to:
  /// **'이름은 12자 이하로 입력해 주세요.'**
  String get setupValidationTooLong;

  /// 요정 생성 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'요정 만들기'**
  String get setupCreateButton;

  /// 종족 라벨 - 정령
  ///
  /// In ko, this message translates to:
  /// **'정령'**
  String get speciesSpirit;

  /// 종족 라벨 - 엘프
  ///
  /// In ko, this message translates to:
  /// **'엘프'**
  String get speciesElf;

  /// 종족 라벨 - 휴먼형
  ///
  /// In ko, this message translates to:
  /// **'휴먼형'**
  String get speciesHumanlike;

  /// 홈 화면 인사
  ///
  /// In ko, this message translates to:
  /// **'안녕, {name}!'**
  String homeGreeting(String name);

  /// 홈 화면 상단 인사
  ///
  /// In ko, this message translates to:
  /// **'{name}와 함께해요'**
  String homeTodayGreeting(String name);

  /// 홈 화면 레벨 라벨
  ///
  /// In ko, this message translates to:
  /// **'레벨 {level}'**
  String homeLevelLabel(int level);

  /// 행동 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'요정과 교감하기'**
  String get homeActionSectionTitle;

  /// 행동 섹션 설명
  ///
  /// In ko, this message translates to:
  /// **'요정과 어떤 놀이를 할까요?'**
  String get homeActionPrompt;

  /// 친밀도 표시
  ///
  /// In ko, this message translates to:
  /// **'친밀도: {count}'**
  String homeAffectionLabel(int count);

  /// 마지막 상호작용 표시
  ///
  /// In ko, this message translates to:
  /// **'마지막 교감: {timestamp}'**
  String homeLastInteraction(String timestamp);

  /// 상호작용 기록 없음
  ///
  /// In ko, this message translates to:
  /// **'아직 교감 기록이 없어요.'**
  String get homeLastInteractionNever;

  /// 리셋 버튼 툴팁
  ///
  /// In ko, this message translates to:
  /// **'요정 리셋'**
  String get homeResetTooltip;

  /// 홈 화면 빠른 링크 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'빠른 이동'**
  String get homeQuickLinksTitle;

  /// AI 채팅 진입 버튼
  ///
  /// In ko, this message translates to:
  /// **'AI와 대화하기'**
  String get homeAiChatButton;

  /// 간식 액션 버튼
  ///
  /// In ko, this message translates to:
  /// **'간식 주기'**
  String get actionFeed;

  /// 놀이 액션 버튼
  ///
  /// In ko, this message translates to:
  /// **'놀아주기'**
  String get actionPlay;

  /// 휴식 액션 버튼
  ///
  /// In ko, this message translates to:
  /// **'재우기'**
  String get actionRest;

  /// 액션 결과 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'요정의 반응'**
  String get dialogActionResultTitle;

  /// 간식 액션 결과
  ///
  /// In ko, this message translates to:
  /// **'{name}가 간식을 맛있게 먹었어요!'**
  String dialogActionResultMessageFeed(String name);

  /// 놀이 액션 결과
  ///
  /// In ko, this message translates to:
  /// **'{name}가 신나게 놀았어요!'**
  String dialogActionResultMessagePlay(String name);

  /// 휴식 액션 결과
  ///
  /// In ko, this message translates to:
  /// **'{name}가 포근한 휴식을 취했어요.'**
  String dialogActionResultMessageRest(String name);

  /// 확인 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get dialogButtonOk;

  /// 취소 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get dialogButtonCancel;

  /// 상태 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'요정 상태'**
  String get statCardTitle;

  /// 기분 수치 라벨
  ///
  /// In ko, this message translates to:
  /// **'기분'**
  String get statMoodLabel;

  /// 배고픔 수치 라벨
  ///
  /// In ko, this message translates to:
  /// **'배고픔'**
  String get statHungerLabel;

  /// 에너지 수치 라벨
  ///
  /// In ko, this message translates to:
  /// **'에너지'**
  String get statEnergyLabel;

  /// 경험치 진행률 라벨
  ///
  /// In ko, this message translates to:
  /// **'경험치 {current}/{goal}'**
  String statExpLabel(int current, int goal);

  /// 마지막 tick 시각
  ///
  /// In ko, this message translates to:
  /// **'마지막 갱신: {timestamp}'**
  String statLastTickLabel(String timestamp);

  /// 랜딩 빈 상태 제목
  ///
  /// In ko, this message translates to:
  /// **'아직 요정을 만들지 않았어요'**
  String get landingEmptyTitle;

  /// 랜딩 빈 상태 설명
  ///
  /// In ko, this message translates to:
  /// **'먼저 요정을 만들어 포근한 친구를 맞이해 보세요.'**
  String get landingEmptyDescription;

  /// 온보딩 이동 버튼
  ///
  /// In ko, this message translates to:
  /// **'요정 만들러 가기'**
  String get landingCreateButton;

  /// 랜딩 기존 요정 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'나의 요정'**
  String get landingExistingTitle;

  /// 홈 이동 버튼
  ///
  /// In ko, this message translates to:
  /// **'요정과 놀러 가기'**
  String get landingOpenButton;

  /// 요정 삭제 버튼
  ///
  /// In ko, this message translates to:
  /// **'요정 삭제'**
  String get landingDeleteButton;

  /// 삭제 확인 제목
  ///
  /// In ko, this message translates to:
  /// **'요정을 초기화할까요?'**
  String get landingDeleteDialogTitle;

  /// 삭제 확인 메시지
  ///
  /// In ko, this message translates to:
  /// **'초기화하면 요정의 모든 성장 기록이 사라집니다.'**
  String get landingDeleteDialogMessage;

  /// 삭제 완료 스낵바 메시지
  ///
  /// In ko, this message translates to:
  /// **'요정을 떠나보냈어요. 새로운 친구를 다시 맞이해 주세요.'**
  String get landingDeletedMessage;

  /// 채팅 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'요정과 대화하기'**
  String get chatTitle;

  /// 빈 채팅 상태 메시지
  ///
  /// In ko, this message translates to:
  /// **'요정과 대화를 시작해보세요!'**
  String get chatEmptyMessage;

  /// 채팅 입력 힌트
  ///
  /// In ko, this message translates to:
  /// **'메시지를 입력하세요...'**
  String get chatInputHint;

  /// 빈 채팅 상태 힌트
  ///
  /// In ko, this message translates to:
  /// **'AI와 대화를 시작해보세요'**
  String get chatEmptyHint;

  /// 대화 기록 삭제 버튼
  ///
  /// In ko, this message translates to:
  /// **'대화 기록 삭제'**
  String get clearHistory;

  /// 대화 기록 삭제 확인 메시지
  ///
  /// In ko, this message translates to:
  /// **'모든 대화 기록을 삭제하시겠습니까?'**
  String get clearHistoryConfirm;

  /// 취소 버튼
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// 삭제 버튼
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get clear;

  /// 재시도 버튼
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// AI 응답 대기 중
  ///
  /// In ko, this message translates to:
  /// **'생각 중...'**
  String get aiThinking;

  /// 모델 선택 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'AI 모델 선택'**
  String get modelSelectionTitle;

  /// 모델 선택 페이지 설명
  ///
  /// In ko, this message translates to:
  /// **'사용할 AI 모델을 선택하세요'**
  String get modelSelectionDescription;

  /// 모델 없음 메시지
  ///
  /// In ko, this message translates to:
  /// **'사용 가능한 모델이 없습니다'**
  String get noModelsFound;

  /// 모델 없음 설명
  ///
  /// In ko, this message translates to:
  /// **'AiModels 폴더에 GGUF 모델 파일을 추가해주세요'**
  String get noModelsDescription;

  /// 현재 선택된 모델 라벨
  ///
  /// In ko, this message translates to:
  /// **'현재 모델'**
  String get currentModel;

  /// 모델 선택 버튼
  ///
  /// In ko, this message translates to:
  /// **'선택'**
  String get selectModel;

  /// 모델 선택 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'모델이 선택되었습니다'**
  String get modelSelected;

  /// 모델 선택 실패 메시지
  ///
  /// In ko, this message translates to:
  /// **'모델 선택에 실패했습니다'**
  String get modelSelectionFailed;

  /// 권한 필요 메시지
  ///
  /// In ko, this message translates to:
  /// **'저장소 권한이 필요합니다'**
  String get permissionRequired;

  /// 권한 요청 버튼
  ///
  /// In ko, this message translates to:
  /// **'권한 요청'**
  String get requestPermission;

  /// 설정 열기 버튼
  ///
  /// In ko, this message translates to:
  /// **'설정 열기'**
  String get openSettings;

  /// 모델 목록 새로고침 버튼
  ///
  /// In ko, this message translates to:
  /// **'새로고침'**
  String get refreshModels;

  /// 모델 디버그 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'AI 디버그 정보'**
  String get modelDebugTitle;

  /// 디버그 정보 새로고침
  ///
  /// In ko, this message translates to:
  /// **'새로고침'**
  String get debugRefresh;

  /// 초기화 상태 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'AI 초기화 상태'**
  String get debugInitStatus;

  /// 모델 정보 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'현재 모델 정보'**
  String get debugModelInfo;

  /// FFI 상태 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'FFI 연결 상태'**
  String get debugFFIStatus;

  /// 시스템 정보 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'시스템 정보'**
  String get debugSystemInfo;

  /// 엔진 상태 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'추론 엔진 상태'**
  String get debugEngineStatus;

  /// 디버그 로그 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'디버그 로그'**
  String get debugLogs;

  /// 로그 복사 버튼
  ///
  /// In ko, this message translates to:
  /// **'로그 복사'**
  String get copyLogs;

  /// 로그 복사 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'로그가 클립보드에 복사되었습니다'**
  String get logsCopied;

  /// 설정 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// AI 설정 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'AI 설정'**
  String get settingsAiSection;

  /// 모델 선택 메뉴
  ///
  /// In ko, this message translates to:
  /// **'AI 모델 선택'**
  String get settingsModelSelection;

  /// 모델 선택 메뉴 설명
  ///
  /// In ko, this message translates to:
  /// **'사용할 AI 모델을 선택하세요'**
  String get settingsModelSelectionDescription;

  /// 디버그 정보 메뉴
  ///
  /// In ko, this message translates to:
  /// **'AI 디버그 정보'**
  String get settingsModelDebug;

  /// 디버그 정보 메뉴 설명
  ///
  /// In ko, this message translates to:
  /// **'AI 모델 상태 및 디버그 정보 확인'**
  String get settingsModelDebugDescription;

  /// 정보 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get settingsAboutSection;

  /// 앱 정보 메뉴
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get settingsAbout;

  /// 앱 정보 설명
  ///
  /// In ko, this message translates to:
  /// **'PokiFairy는 포켓 페어리 컴패니언과 AI 어시스턴트가 결합된 앱입니다.'**
  String get settingsAboutDescription;

  /// 모델 없음 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'사용 가능한 AI 모델이 없습니다. 모델을 다운로드해주세요.'**
  String get errorModelNotFound;

  /// 모델 로드 실패 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'AI 모델을 불러오는데 실패했습니다. 모델 파일을 확인해주세요.'**
  String get errorModelLoadFailed;

  /// 추론 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'AI 응답 생성 중 오류가 발생했습니다. 다시 시도해주세요.'**
  String get errorInference;

  /// 권한 거부 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'저장소 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.'**
  String get errorPermissionDenied;

  /// 메모리 부족 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'메모리가 부족합니다. 다른 앱을 종료하고 다시 시도해주세요.'**
  String get errorInsufficientMemory;

  /// 네트워크 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해주세요.'**
  String get errorNetwork;

  /// 알 수 없는 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 발생했습니다.'**
  String get errorUnknown;

  /// 방금 전 메시지 타임스탬프
  ///
  /// In ko, this message translates to:
  /// **'방금 전'**
  String get justNow;

  /// 분 단위 타임스탬프
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 전'**
  String minutesAgo(int minutes);

  /// 일 단위 타임스탬프
  ///
  /// In ko, this message translates to:
  /// **'{days}일 전'**
  String daysAgo(int days);

  /// 권한 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'권한 필요'**
  String get permissionDialogTitle;

  /// 권한 다이얼로그 메시지
  ///
  /// In ko, this message translates to:
  /// **'AI 모델에 접근하기 위해 저장소 권한이 필요합니다. 권한을 허용해주세요.'**
  String get permissionDialogMessage;

  /// 권한 다이얼로그 취소 버튼
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get permissionDialogCancel;

  /// 권한 다이얼로그 허용 버튼
  ///
  /// In ko, this message translates to:
  /// **'권한 허용'**
  String get permissionDialogAllow;

  /// 권한 설정 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'권한 설정 필요'**
  String get permissionSettingsTitle;

  /// 권한 설정 다이얼로그 메시지
  ///
  /// In ko, this message translates to:
  /// **'권한이 거부되었습니다. 설정에서 권한을 허용해주세요.'**
  String get permissionSettingsMessage;

  /// 메시지 전송 버튼
  ///
  /// In ko, this message translates to:
  /// **'전송'**
  String get sendMessage;

  /// 모델 없음 제목
  ///
  /// In ko, this message translates to:
  /// **'AI 모델이 없습니다'**
  String get noModelTitle;

  /// 모델 없음 설명
  ///
  /// In ko, this message translates to:
  /// **'AI와 대화하려면 먼저 모델을 선택해주세요.'**
  String get noModelDescription;

  /// 모델 선택 화면으로 이동 버튼
  ///
  /// In ko, this message translates to:
  /// **'모델 선택하기'**
  String get goToModelSelection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
