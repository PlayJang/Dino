import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/image_processing/image_processing_isolate.dart';
import '../../../core/platform/app_platform.dart';
import '../../../l10n/l10n_extensions.dart';
import '../../../providers/app_providers.dart';
import '../../../services/camera/camera_capture_service_base.dart';
import '../../../shared/widgets/protection_widgets.dart';
import '../application/protection_controller.dart';
import '../domain/protection_models.dart';
import 'camera_capture_screen.dart';
import 'processing_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _openCameraFlow() async {
    final controller = ref.read(protectionControllerProvider.notifier);
    controller.setCameraOpening();

    final capture = await Navigator.of(context).push<CapturedImageInput>(
      MaterialPageRoute<CapturedImageInput>(
        builder: (_) => const CameraCaptureScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (capture == null) {
      controller.cancelPendingAction();
      return;
    }

    final record = await controller.processBytes(
      bytes: capture.bytes,
      sourceKind: SourceKind.camera,
      sourceName: capture.sourceName,
    );

    if (!mounted || record == null) {
      return;
    }

    _openProcessingScreen();
  }

  Future<void> _openGalleryFlow() async {
    final record = await ref
        .read(protectionControllerProvider.notifier)
        .pickAndProcessImage();

    if (!mounted || record == null) {
      return;
    }

    _openProcessingScreen();
  }

  Future<void> _verifyWatermarkFlow() async {
    final input = await ref.read(imageImportServiceProvider).pickImage();

    if (!mounted || input == null) {
      return;
    }

    final result = await verifyDinoWatermarkOnWorker(input.bytes);

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return _WatermarkVerificationDialog(
          fileName: input.sourceName,
          result: result,
        );
      },
    );
  }

  void _openProcessingScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ProcessingScreen()));
  }

  void _openSettingsScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProtectionState>(protectionControllerProvider, (previous, next) {
      final message = next.errorMessage ?? next.statusMessage;

      if (message == null ||
          message == previous?.errorMessage ||
          message == previous?.statusMessage) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: next.errorMessage == null
                ? Theme.of(context).colorScheme.inverseSurface
                : Theme.of(context).colorScheme.error,
          ),
        );
    });

    final state = ref.watch(protectionControllerProvider);
    final controller = ref.read(protectionControllerProvider.notifier);
    final platform = ref.watch(appPlatformProvider);
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DinoBrandMark(size: 32),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            onPressed: state.isBusy ? null : _openSettingsScreen,
            icon: const Icon(Icons.tune_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  sliver: SliverList.list(
                    children: [
                      _HeroStatusCard(
                        state: state,
                        platform: platform,
                        onCamera: _openCameraFlow,
                        onGallery: _openGalleryFlow,
                        onVerify: _verifyWatermarkFlow,
                      ),
                      const SizedBox(height: 16),
                      const _OnboardingCard(),
                      const SizedBox(height: 16),
                      _RecentPreviewCard(
                        record: state.activeRecord,
                        onOpen: state.activeRecord == null
                            ? null
                            : _openProcessingScreen,
                      ),
                      const SizedBox(height: 16),
                      _QuickSettingsStrip(
                        settings: state.settings,
                        platform: platform,
                        activeRecord: state.activeRecord,
                        onModeChanged: controller.setProtectionMode,
                        onOpenSettings: _openSettingsScreen,
                      ),
                      const SizedBox(height: 16),
                      if (state.history.isNotEmpty)
                        _HistorySection(
                          records: state.history,
                          onSelected: (record) {
                            ref
                                .read(protectionControllerProvider.notifier)
                                .selectRecord(record);
                            _openProcessingScreen();
                          },
                        )
                      else
                        AppCard(
                          color: scheme.surfaceContainerLow,
                          child: Row(
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.noProcessedImagesYet,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            BusyOverlay(stage: state.stage),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.lightbulb_outline,
            title: l10n.onboardingTitle,
          ),
          const SizedBox(height: 12),
          _OnboardingStep(
            index: 1,
            icon: Icons.add_photo_alternate_outlined,
            text: l10n.onboardingStepChoose,
          ),
          _OnboardingStep(
            index: 2,
            icon: Icons.shield_outlined,
            text: l10n.onboardingStepProtect,
          ),
          _OnboardingStep(
            index: 3,
            icon: Icons.verified_user_outlined,
            text: l10n.onboardingStepExport,
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.index,
    required this.icon,
    required this.text,
  });

  final int index;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Text(
              '$index',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatusCard extends StatelessWidget {
  const _HeroStatusCard({
    required this.state,
    required this.platform,
    required this.onCamera,
    required this.onGallery,
    required this.onVerify,
  });

  final ProtectionState state;
  final AppPlatform platform;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return AppCard(
      color: scheme.primaryContainer.withValues(alpha: 0.92),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DinoHeroBadge(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeHeadline,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: 0,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.homeSubtitle,
                      style: TextStyle(
                        color: scheme.onPrimaryContainer.withValues(
                          alpha: 0.78,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.brandPromise,
                      style: TextStyle(
                        color: scheme.onPrimaryContainer.withValues(
                          alpha: 0.70,
                        ),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusPill(
                      icon: Icons.lock_outline,
                      label: l10n.localProcessing,
                      color: scheme.tertiary,
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: Text(
                        state.isBusy
                            ? state.stage.localizedLabel(l10n)
                            : state.activeRecord == null
                            ? l10n.readyOnPlatform(platform.platformLabel)
                            : l10n.latestOutputReady,
                        key: ValueKey<String>(
                          '${state.stage}-${state.activeRecord?.outputPath}',
                        ),
                        style: TextStyle(
                          color: scheme.onPrimaryContainer.withValues(
                            alpha: 0.82,
                          ),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state.isBusy) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(borderRadius: BorderRadius.circular(8)),
          ],
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 520;
              final cameraButton = FilledButton.icon(
                onPressed: state.isBusy ? null : onCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.capturePhoto),
              );
              final galleryButton = FilledButton.tonalIcon(
                onPressed: state.isBusy ? null : onGallery,
                icon: Icon(
                  platform.usesDesktopFilePicker
                      ? Icons.upload_file_outlined
                      : Icons.photo_library_outlined,
                ),
                label: Text(l10n.uploadImage),
              );
              final verifyButton = OutlinedButton.icon(
                onPressed: state.isBusy ? null : onVerify,
                icon: const Icon(Icons.verified_user_outlined),
                label: Text(l10n.verifyWatermark),
              );

              if (!platform.supportsCameraCapture) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: double.infinity, child: galleryButton),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: verifyButton),
                  ],
                );
              }

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: cameraButton),
                    const SizedBox(width: 10),
                    Expanded(child: galleryButton),
                    const SizedBox(width: 10),
                    Expanded(child: verifyButton),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: double.infinity, child: cameraButton),
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: galleryButton),
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: verifyButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WatermarkVerificationDialog extends StatelessWidget {
  const _WatermarkVerificationDialog({
    required this.fileName,
    required this.result,
  });

  final String fileName;
  final WatermarkVerificationResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final metadata = result.metadata;

    return AlertDialog(
      icon: Icon(
        result.detected
            ? Icons.verified_user_outlined
            : Icons.help_outline_rounded,
        color: result.detected ? scheme.primary : scheme.onSurfaceVariant,
      ),
      title: Text(
        result.detected ? l10n.watermarkPresent : l10n.watermarkMissing,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(l10n.watermarkHelp),
          const SizedBox(height: 12),
          _DialogMetric(
            label: l10n.watermarkConfidence,
            value: '${(result.confidence * 100).round()}%',
          ),
          if (metadata != null) ...[
            _DialogMetric(
              label: l10n.watermarkMode,
              value: metadata.mode.localizedLabel(l10n),
            ),
            _DialogMetric(
              label: l10n.watermarkProtectedAt,
              value: metadata.protectedAtIso,
            ),
            _DialogMetric(
              label: l10n.watermarkFingerprint,
              value: metadata.fingerprint,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

class _DialogMetric extends StatelessWidget {
  const _DialogMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPreviewCard extends StatelessWidget {
  const _RecentPreviewCard({required this.record, required this.onOpen});

  final ProtectedImageRecord? record;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeRecord = record;
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.auto_awesome_outlined,
            title: l10n.recentProcessedImage,
            trailing: activeRecord == null
                ? null
                : TextButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new_outlined),
                    label: Text(l10n.open),
                  ),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ImageSurface(
              bytes: activeRecord?.processedBytes,
              fit: BoxFit.cover,
              icon: Icons.add_photo_alternate_outlined,
            ),
          ),
          if (activeRecord != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusPill(
                  icon: switch (activeRecord.sourceKind) {
                    SourceKind.camera => Icons.photo_camera_outlined,
                    SourceKind.gallery => Icons.photo_library_outlined,
                    SourceKind.file => Icons.insert_drive_file_outlined,
                  },
                  label: activeRecord.sourceKind.localizedLabel(l10n),
                ),
                StatusPill(
                  icon: Icons.speed_outlined,
                  label: '${activeRecord.metrics.elapsedMilliseconds} ms',
                  color: scheme.secondary,
                ),
                StatusPill(
                  icon: Icons.high_quality_outlined,
                  label: activeRecord.metrics.psnr.isInfinite
                      ? 'PSNR inf'
                      : 'PSNR ${activeRecord.metrics.psnr.toStringAsFixed(1)}',
                  color: scheme.tertiary,
                ),
                if (activeRecord.isSaved)
                  StatusPill(
                    icon: Icons.check_circle_outline,
                    label: l10n.saved,
                    color: scheme.primary,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickSettingsStrip extends StatelessWidget {
  const _QuickSettingsStrip({
    required this.settings,
    required this.platform,
    required this.activeRecord,
    required this.onModeChanged,
    required this.onOpenSettings,
  });

  final ProcessingSettings settings;
  final AppPlatform platform;
  final ProtectedImageRecord? activeRecord;
  final ValueChanged<ProtectionMode> onModeChanged;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.shield_outlined,
            title: l10n.quickProtection,
            trailing: IconButton(
              tooltip: l10n.settings,
              onPressed: onOpenSettings,
              icon: const Icon(Icons.tune_outlined),
            ),
          ),
          const SizedBox(height: 12),
          ProtectionModeSelector(
            selected: settings.mode,
            onChanged: onModeChanged,
          ),
          const SizedBox(height: 8),
          ProtectionModeSummary(mode: settings.mode),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                icon: Icons.tag_outlined,
                label: 'Seed ${settings.seed}',
              ),
              StatusPill(
                icon: Icons.graphic_eq_outlined,
                label:
                    '${(settings.protectionStrength * 100).round()}% ${l10n.quickProtection}',
                color: scheme.secondary,
              ),
              StatusPill(
                icon: Icons.image_outlined,
                label: settings.exportFormat.label,
                color: scheme.tertiary,
              ),
              StatusPill(
                icon: Icons.devices_outlined,
                label: platform.platformLabel,
                color: scheme.primary,
              ),
            ],
          ),
          if (activeRecord != null) ...[
            const SizedBox(height: 12),
            ResistanceScoreCard(metrics: activeRecord!.metrics),
          ],
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.records, required this.onSelected});

  final List<ProtectedImageRecord> records;
  final ValueChanged<ProtectedImageRecord> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionHeader(
            icon: Icons.history_outlined,
            title: l10n.recentOutputs,
          ),
          const SizedBox(height: 8),
          for (final record in records)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox.square(
                  dimension: 52,
                  child: Image.memory(
                    record.processedBytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              title: Text(
                record.sourceName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${record.settings.exportFormat.label} - seed ${record.settings.seed} - ${record.metrics.elapsedMilliseconds} ms',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelected(record),
            ),
        ],
      ),
    );
  }
}
