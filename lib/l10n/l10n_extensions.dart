import 'package:flutter/widgets.dart';

import '../features/protection/domain/protection_models.dart';
import 'generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension LocalizedSourceKind on SourceKind {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    SourceKind.camera => l10n.sourceCamera,
    SourceKind.gallery => l10n.sourceGallery,
    SourceKind.file => l10n.sourceFile,
  };
}

extension LocalizedProcessingStage on ProcessingStage {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ProcessingStage.idle => l10n.stageIdle,
    ProcessingStage.picking => l10n.stagePicking,
    ProcessingStage.capturing => l10n.stageCapturing,
    ProcessingStage.processing => l10n.stageProcessing,
    ProcessingStage.saving => l10n.stageSaving,
  };
}

extension LocalizedProtectionMode on ProtectionMode {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ProtectionMode.social => l10n.modeNatural,
    ProtectionMode.balanced => l10n.modeBalanced,
    ProtectionMode.maximum => l10n.modeMaximum,
  };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
    ProtectionMode.social => l10n.modeNaturalDescription,
    ProtectionMode.balanced => l10n.modeBalancedDescription,
    ProtectionMode.maximum => l10n.modeMaximumDescription,
  };
}

extension LocalizedProcessingMetrics on ProcessingMetrics {
  String resistanceLevel(AppLocalizations l10n) {
    if (aiResistanceScore >= 0.78) {
      return l10n.resistanceLevelMaximum;
    }

    if (aiResistanceScore >= 0.58) {
      return l10n.resistanceLevelHigh;
    }

    if (aiResistanceScore >= 0.34) {
      return l10n.resistanceLevelMedium;
    }

    return l10n.resistanceLevelLow;
  }
}

extension LocalizedImageProfile on ImageProfile {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ImageProfile.portrait => l10n.profilePortrait,
    ImageProfile.landscape => l10n.profileLandscape,
    ImageProfile.illustration => l10n.profileIllustration,
    ImageProfile.lowDetail => l10n.profileLowDetail,
    ImageProfile.textureHeavy => l10n.profileTextureHeavy,
    ImageProfile.general => l10n.profileGeneral,
  };
}
