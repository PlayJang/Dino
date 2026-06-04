import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n_extensions.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/protection_widgets.dart';
import '../application/protection_controller.dart';
import '../domain/protection_models.dart';
import 'settings_screen.dart';

class ProcessingScreen extends ConsumerWidget {
  const ProcessingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final record = state.activeRecord;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.protectedImage),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            onPressed: state.isBusy
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
            icon: const Icon(Icons.tune_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (record == null)
              const _NoResultView()
            else
              _ResultView(
                record: record,
                isBusy: state.isBusy,
                onSave: controller.saveActiveImage,
                onReprocess: controller.reprocessActiveImage,
              ),
            BusyOverlay(stage: state.stage),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatefulWidget {
  const _ResultView({
    required this.record,
    required this.isBusy,
    required this.onSave,
    required this.onReprocess,
  });

  final ProtectedImageRecord record;
  final bool isBusy;
  final VoidCallback onSave;
  final VoidCallback onReprocess;

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  bool _showHeatmap = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final record = widget.record;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          sliver: SliverList.list(
            children: [
              AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      icon: Icons.compare_outlined,
                      title: l10n.beforeAfter,
                      trailing: StatusPill(
                        icon: record.isSaved
                            ? Icons.check_circle_outline
                            : Icons.lock_outline,
                        label: record.isSaved ? l10n.saved : l10n.ready,
                        color: record.isSaved
                            ? scheme.primary
                            : scheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilterChip(
                      selected: _showHeatmap,
                      avatar: const Icon(Icons.local_fire_department_outlined),
                      label: Text(l10n.heatmapOverlay),
                      onSelected: (value) {
                        setState(() {
                          _showHeatmap = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    BeforeAfterSlider(
                      originalBytes: record.originalBytes,
                      processedBytes: record.processedBytes,
                      heatmapBytes: record.heatmapBytes,
                      showHeatmap: _showHeatmap,
                    ),
                    if (_showHeatmap) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.heatmapHelp,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ActionBar(
                record: record,
                isBusy: widget.isBusy,
                onSave: widget.onSave,
                onReprocess: widget.onReprocess,
              ),
              const SizedBox(height: 16),
              _PreviewPair(record: record),
              const SizedBox(height: 16),
              _DisruptionDashboard(metrics: record.metrics),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      icon: Icons.insights_outlined,
                      title: l10n.qualityMetrics,
                    ),
                    const SizedBox(height: 12),
                    MetricsGrid(metrics: record.metrics),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill(
                      icon: switch (record.sourceKind) {
                        SourceKind.camera => Icons.photo_camera_outlined,
                        SourceKind.gallery => Icons.photo_library_outlined,
                        SourceKind.file => Icons.insert_drive_file_outlined,
                      },
                      label: record.sourceKind.localizedLabel(l10n),
                    ),
                    StatusPill(
                      icon: Icons.tag_outlined,
                      label: 'Seed ${record.settings.seed}',
                      color: scheme.secondary,
                    ),
                    StatusPill(
                      icon: Icons.graphic_eq_outlined,
                      label:
                          '${(record.settings.protectionStrength * 100).round()}% ${l10n.quickProtection}',
                      color: scheme.tertiary,
                    ),
                    StatusPill(
                      icon: Icons.image_outlined,
                      label: record.settings.exportFormat.label,
                      color: scheme.primary,
                    ),
                    StatusPill(
                      icon: Icons.verified_user_outlined,
                      label:
                          '${l10n.watermark}: ${record.metrics.watermarkFingerprint.substring(0, 8)}',
                      color: scheme.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisruptionDashboard extends StatelessWidget {
  const _DisruptionDashboard({required this.metrics});

  final ProcessingMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ResistanceScoreCard(metrics: metrics),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                icon: Icons.radar_outlined,
                title: l10n.disruptionMetrics,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.estimatedMetricsNote,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final rings = [
                    MetricRing(
                      value: metrics.featureDisruptionScore,
                      label: l10n.featureDisruption,
                      centerLabel:
                          '${(metrics.featureDisruptionScore * 100).round()}',
                      color: scheme.primary,
                    ),
                    MetricRing(
                      value: metrics.embeddingInstabilityEstimate,
                      label: l10n.embeddingInstability,
                      centerLabel:
                          '${(metrics.embeddingInstabilityEstimate * 100).round()}',
                      color: scheme.secondary,
                    ),
                    MetricRing(
                      value: metrics.styleDisruptionEstimate,
                      label: l10n.styleDisruption,
                      centerLabel:
                          '${(metrics.styleDisruptionEstimate * 100).round()}',
                      color: scheme.tertiary,
                    ),
                    MetricRing(
                      value: metrics.semanticConfusionEstimate,
                      label: l10n.semanticConfusion,
                      centerLabel:
                          '${(metrics.semanticConfusionEstimate * 100).round()}',
                      color: scheme.secondary,
                    ),
                    MetricRing(
                      value: metrics.reinterpretationResistanceEstimate,
                      label: l10n.reinterpretationResistance,
                      centerLabel:
                          '${(metrics.reinterpretationResistanceEstimate * 100).round()}',
                      color: scheme.tertiary,
                    ),
                    MetricRing(
                      value: metrics.imageFidelityEstimate,
                      label: l10n.imageFidelity,
                      centerLabel:
                          '${(metrics.imageFidelityEstimate * 100).round()}',
                      color: scheme.primary,
                    ),
                  ];

                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    alignment: WrapAlignment.spaceAround,
                    children: rings,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.record,
    required this.isBusy,
    required this.onSave,
    required this.onReprocess,
  });

  final ProtectedImageRecord record;
  final bool isBusy;
  final VoidCallback onSave;
  final VoidCallback onReprocess;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;
        final buttons = [
          FilledButton.icon(
            onPressed: isBusy ? null : onSave,
            icon: const Icon(Icons.save_alt_outlined),
            label: Text(l10n.exportFormat(record.settings.exportFormat.label)),
          ),
          OutlinedButton.icon(
            onPressed: isBusy ? null : onReprocess,
            icon: const Icon(Icons.autorenew_outlined),
            label: Text(l10n.reprocess),
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              for (var index = 0; index < buttons.length; index++) ...[
                Expanded(child: buttons[index]),
                if (index != buttons.length - 1) const SizedBox(width: 10),
              ],
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: buttons[0]),
                const SizedBox(width: 10),
                Expanded(child: buttons[1]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PreviewPair extends StatelessWidget {
  const _PreviewPair({required this.record});

  final ProtectedImageRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final original = _PreviewTile(
          title: l10n.original,
          bytes: record.originalBytes,
          icon: Icons.image_search_outlined,
        );
        final processed = _PreviewTile(
          title: l10n.protected,
          bytes: record.processedBytes,
          icon: Icons.enhanced_encryption_outlined,
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: original),
              const SizedBox(width: 12),
              Expanded(child: processed),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [original, const SizedBox(height: 12), processed],
        );
      },
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.title,
    required this.bytes,
    required this.icon,
  });

  final String title;
  final Uint8List bytes;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: icon,
            title: title,
            trailing: IconButton(
              tooltip: l10n.zoom,
              onPressed: () => _showImageDetail(context),
              icon: const Icon(Icons.zoom_out_map_outlined),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showImageDetail(context),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: ImageSurface(bytes: bytes, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDetail(BuildContext context) {
    final l10n = context.l10n;

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.imageDetails),
              leading: IconButton(
                tooltip: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
            body: InteractiveViewer(
              minScale: 0.5,
              maxScale: 6,
              child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
            ),
          ),
        );
      },
    );
  }
}

class _NoResultView extends StatelessWidget {
  const _NoResultView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: scheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noImageProcessed,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.captureOrImport,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
