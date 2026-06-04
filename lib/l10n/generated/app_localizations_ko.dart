// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '디노';

  @override
  String get homeHeadline => '공유하기 전에 이미지를 보호하세요';

  @override
  String get homeSubtitle => '디노는 AI 복제와 딥페이크 재사용을 더 어렵게 만드는 은근한 보호막을 추가합니다.';

  @override
  String get brandPromise => '사진, 그림, 스크린샷, 일상 이미지를 위한 친근한 보호.';

  @override
  String get estimatedMetricsNote => '점수는 기기에서 계산한 추정치이며 AI 시스템 차단을 보장하지 않습니다.';

  @override
  String get dinoMascotLabel => '디노 개인정보 보호 마스코트';

  @override
  String get localProcessing => '모든 처리는 이 기기에서만 이루어집니다.';

  @override
  String get capturePhoto => '사진 촬영';

  @override
  String get uploadImage => '이미지 업로드';

  @override
  String get verifyWatermark => '디노 마크 확인';

  @override
  String get recentProcessedImage => '최근 처리 이미지';

  @override
  String get open => '열기';

  @override
  String readyOnPlatform(Object platform) {
    return '$platform에서 준비됨';
  }

  @override
  String get latestOutputReady => '최신 결과가 준비되었습니다';

  @override
  String get noProcessedImagesYet => '아직 처리된 이미지가 없습니다';

  @override
  String get quickProtection => '보호';

  @override
  String get protectionMode => '보호 모드';

  @override
  String get modeNatural => 'SNS 공유용';

  @override
  String get modeBalanced => '균형';

  @override
  String get modeMaximum => '최대 개인정보 보호';

  @override
  String get modeNaturalDescription => '눈에 띄는 변화가 가장 적어 일상 공유에 좋습니다.';

  @override
  String get modeBalancedDescription => '대부분의 사진, 그림, 스크린샷에 추천하는 보호입니다.';

  @override
  String get modeMaximumDescription => '아주 작은 품질 변화보다 개인정보 보호가 더 중요할 때 사용하세요.';

  @override
  String get recommended => '추천';

  @override
  String get onboardingTitle => '디노 사용 방법';

  @override
  String get onboardingStepChoose => '사진, 그림, 스크린샷 또는 웹캠 이미지를 선택하세요.';

  @override
  String get onboardingStepProtect => '보호 모드를 고르세요. 균형 모드를 추천합니다.';

  @override
  String get onboardingStepExport => '숨겨진 디노 마크가 들어간 보호 사본을 저장하세요.';

  @override
  String get aiResistance => 'AI 저항력';

  @override
  String get resistanceLevelLow => '낮음';

  @override
  String get resistanceLevelMedium => '중간';

  @override
  String get resistanceLevelHigh => '높음';

  @override
  String get resistanceLevelMaximum => '최대';

  @override
  String get settings => '설정';

  @override
  String get recentOutputs => '최근 결과';

  @override
  String get protectedImage => '보호된 이미지';

  @override
  String get beforeAfter => '전 / 후 비교';

  @override
  String get protected => '보호됨';

  @override
  String get original => '원본';

  @override
  String get ready => '준비됨';

  @override
  String get saved => '저장됨';

  @override
  String exportFormat(Object format) {
    return '$format 저장';
  }

  @override
  String get reprocess => '다시 처리';

  @override
  String get qualityMetrics => '품질 지표';

  @override
  String get disruptionMetrics => 'AI 교란 지표';

  @override
  String get featureDisruption => '특징 교란';

  @override
  String get embeddingInstability => '임베딩 불안정성';

  @override
  String get styleDisruption => '스타일 교란';

  @override
  String get semanticConfusion => '의미 혼란';

  @override
  String get reinterpretationResistance => '재해석 저항력';

  @override
  String get imageFidelity => '이미지 충실도';

  @override
  String get resistanceScore => '저항 점수';

  @override
  String get imageType => '이미지 종류';

  @override
  String get textureComplexity => '질감 디테일';

  @override
  String get semanticCoverage => '중요 영역';

  @override
  String get watermark => '숨겨진 디노 마크';

  @override
  String get watermarkPresent => '디노 마크 발견';

  @override
  String get watermarkMissing => '디노 마크 없음';

  @override
  String get watermarkConfidence => '신뢰도';

  @override
  String get watermarkFingerprint => '지문';

  @override
  String get watermarkProtectedAt => '보호 시간';

  @override
  String get watermarkMode => '모드';

  @override
  String get watermarkHelp =>
      '디노는 나중에 확인할 수 있도록 보호 이미지 안에 작은 서명을 숨깁니다. 손실 압축으로 마크가 사라질 수 있습니다.';

  @override
  String get imageDetails => '이미지 상세';

  @override
  String get zoom => '확대';

  @override
  String get heatmapOverlay => '히트맵 오버레이';

  @override
  String get heatmapHelp => '따뜻한 색 영역은 디노가 이 이미지에 구조화된 보호를 더 많이 적용한 부분입니다.';

  @override
  String get scanProtecting => '적대적 보호막 생성 중...';

  @override
  String get noImageProcessed => '처리된 이미지 없음';

  @override
  String get captureOrImport => '홈 화면에서 이미지를 촬영하거나 업로드하세요.';

  @override
  String get deterministicSeed => '결정적 시드';

  @override
  String get seed => '시드';

  @override
  String get applySeed => '시드 적용';

  @override
  String get seedValidation => '시드는 정수여야 합니다.';

  @override
  String get protectionControls => '간단 설정';

  @override
  String get protectionStrength => 'AI 보호력';

  @override
  String get edgeSensitivity => '중요한 이미지 디테일 보호';

  @override
  String get frequencyStrength => '압축 보호';

  @override
  String get faceWeighting => '얼굴 특징 보호';

  @override
  String get rgbLsbDepth => '숨김 마크 강도';

  @override
  String get protectionStrengthHelp =>
      '보호를 높이면 AI 복제가 더 어려워지지만 이미지 품질이 아주 조금 달라질 수 있습니다.';

  @override
  String get edgeSensitivityHelp => '윤곽선, 물체 경계, 붓 터치 같은 중요한 부분을 더 신경 씁니다.';

  @override
  String get frequencyStrengthHelp => '리사이즈나 가벼운 압축 후에도 보호가 남도록 돕습니다.';

  @override
  String get faceWeightingHelp => '사람이 있을 때 눈, 입, 머리카락, 얼굴형 주변을 더 보호합니다.';

  @override
  String get lsbDepthHelp => '보이지 않는 확인용 디노 마크를 얼마나 강하게 숨길지 정합니다.';

  @override
  String get oneBit => '1비트';

  @override
  String get twoBits => '2비트';

  @override
  String get export => '저장';

  @override
  String get format => '형식';

  @override
  String get jpegQuality => 'JPEG 품질';

  @override
  String get jpegQualityHelp => '품질을 높이면 디테일을 더 보존하고 숨겨진 마크를 읽을 가능성도 높아집니다.';

  @override
  String get livePreview => '실시간 미리보기';

  @override
  String get livePreviewEmpty => '설정 변경을 미리 보려면 이미지를 선택하세요.';

  @override
  String get theme => '테마';

  @override
  String get systemTheme => '시스템';

  @override
  String get lightTheme => '라이트';

  @override
  String get darkTheme => '다크';

  @override
  String get reset => '초기화';

  @override
  String get apply => '적용';

  @override
  String get language => '언어';

  @override
  String get english => '영어';

  @override
  String get korean => '한국어';

  @override
  String get webcamCapture => '카메라 촬영';

  @override
  String get close => '닫기';

  @override
  String get checkingWebcam => '카메라 확인 중...';

  @override
  String get windowsWebcam => 'Windows 웹캠';

  @override
  String get retry => '다시 시도';

  @override
  String get capture => '촬영';

  @override
  String get cameraUnavailable => '이 기기에서는 카메라 촬영을 사용할 수 없습니다.';

  @override
  String get sourceCamera => '카메라';

  @override
  String get sourceGallery => '갤러리';

  @override
  String get sourceFile => '파일';

  @override
  String get stageIdle => '준비됨';

  @override
  String get stagePicking => '이미지 선택 중';

  @override
  String get stageCapturing => '카메라 여는 중';

  @override
  String get stageProcessing => '처리 중';

  @override
  String get stageSaving => '저장 중';

  @override
  String get metricTouched => '변경 픽셀';

  @override
  String get metricPerturbation => '교란';

  @override
  String get metricFrequency => '주파수';

  @override
  String get metricTime => '시간';

  @override
  String get metricSize => '크기';

  @override
  String get profilePortrait => '인물';

  @override
  String get profileLandscape => '풍경';

  @override
  String get profileIllustration => '일러스트';

  @override
  String get profileLowDetail => '단순 이미지';

  @override
  String get profileTextureHeavy => '질감 많은 이미지';

  @override
  String get profileGeneral => '일반 이미지';
}
