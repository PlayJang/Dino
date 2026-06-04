import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../features/protection/domain/protection_models.dart';
import '../../l10n/l10n_extensions.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: color,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: scheme.onSurface, letterSpacing: 0),
          child: child,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.icon,
    required this.label,
    this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pillColor = color ?? scheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: pillColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: pillColor),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class DinoBrandMark extends StatelessWidget {
  const DinoBrandMark({this.size = 56, this.showShield = true, super.key});

  final double size;
  final bool showShield;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      image: true,
      label: context.l10n.dinoMascotLabel,
      child: SizedBox.square(
        dimension: size,
        child: Image.asset(
          'assets/branding/dinosaur_logo.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return CustomPaint(
              painter: _DinoBrandPainter(
                body: scheme.primary,
                belly: scheme.primaryContainer,
                accent: scheme.secondary,
                outline: scheme.onSurface,
                shield: scheme.tertiary,
                showShield: showShield,
              ),
            );
          },
        ),
      ),
    );
  }
}

class DinoHeroBadge extends StatelessWidget {
  const DinoHeroBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.82),
            scheme.secondaryContainer.withValues(alpha: 0.62),
          ],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.24)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: DinoBrandMark(size: 76),
      ),
    );
  }
}

class ProtectionModeSelector extends StatelessWidget {
  const ProtectionModeSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ProtectionMode selected;
  final ValueChanged<ProtectionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SegmentedButton<ProtectionMode>(
      selected: <ProtectionMode>{selected},
      showSelectedIcon: false,
      segments: [
        ButtonSegment<ProtectionMode>(
          value: ProtectionMode.social,
          icon: const Icon(Icons.eco_outlined),
          label: Text(l10n.modeNatural),
        ),
        ButtonSegment<ProtectionMode>(
          value: ProtectionMode.balanced,
          icon: const Icon(Icons.shield_outlined),
          label: Text(l10n.modeBalanced),
        ),
        ButtonSegment<ProtectionMode>(
          value: ProtectionMode.maximum,
          icon: const Icon(Icons.enhanced_encryption_outlined),
          label: Text(l10n.modeMaximum),
        ),
      ],
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class ProtectionModeSummary extends StatelessWidget {
  const ProtectionModeSummary({required this.mode, super.key});

  final ProtectionMode mode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Text(
        mode.localizedDescription(l10n),
        key: ValueKey<ProtectionMode>(mode),
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _DinoBrandPainter extends CustomPainter {
  const _DinoBrandPainter({
    required this.body,
    required this.belly,
    required this.accent,
    required this.outline,
    required this.shield,
    required this.showShield,
  });

  final Color body;
  final Color belly;
  final Color accent;
  final Color outline;
  final Color shield;
  final bool showShield;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = outline.withValues(alpha: 0.36);

    final bodyPaint = Paint()..color = body;
    final bellyPaint = Paint()..color = belly;
    final accentPaint = Paint()..color = accent;
    final eyePaint = Paint()..color = outline;
    final shieldPaint = Paint()..color = shield.withValues(alpha: 0.88);

    final head = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.14, s * 0.20, s * 0.56, s * 0.56),
      Radius.circular(s * 0.18),
    );
    canvas.drawRRect(head, bodyPaint);
    canvas.drawRRect(head, stroke);

    final snout = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.44, s * 0.39, s * 0.38, s * 0.24),
      Radius.circular(s * 0.10),
    );
    canvas.drawRRect(snout, bodyPaint);
    canvas.drawRRect(snout, stroke);

    final bellyShape = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.22, s * 0.50, s * 0.28, s * 0.20),
      Radius.circular(s * 0.09),
    );
    canvas.drawRRect(bellyShape, bellyPaint);

    final crest = Path()
      ..moveTo(s * 0.22, s * 0.23)
      ..lineTo(s * 0.27, s * 0.10)
      ..lineTo(s * 0.34, s * 0.23)
      ..lineTo(s * 0.40, s * 0.10)
      ..lineTo(s * 0.47, s * 0.23);
    canvas.drawPath(
      crest,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.05
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = accentPaint.color,
    );

    canvas.drawCircle(Offset(s * 0.39, s * 0.38), s * 0.035, eyePaint);
    canvas.drawCircle(Offset(s * 0.64, s * 0.48), s * 0.016, eyePaint);
    canvas.drawCircle(Offset(s * 0.73, s * 0.48), s * 0.014, eyePaint);

    final smile = Path()
      ..moveTo(s * 0.53, s * 0.57)
      ..quadraticBezierTo(s * 0.62, s * 0.64, s * 0.75, s * 0.58);
    canvas.drawPath(smile, stroke);

    if (!showShield) {
      return;
    }

    final shieldPath = Path()
      ..moveTo(s * 0.66, s * 0.68)
      ..lineTo(s * 0.88, s * 0.76)
      ..lineTo(s * 0.84, s * 0.92)
      ..quadraticBezierTo(s * 0.77, s * 1.01, s * 0.66, s * 0.96)
      ..quadraticBezierTo(s * 0.55, s * 1.01, s * 0.48, s * 0.92)
      ..lineTo(s * 0.44, s * 0.76)
      ..close();
    canvas.drawPath(shieldPath, shieldPaint);
    canvas.drawPath(shieldPath, stroke);

    final check = Path()
      ..moveTo(s * 0.56, s * 0.84)
      ..lineTo(s * 0.63, s * 0.90)
      ..lineTo(s * 0.76, s * 0.78);
    canvas.drawPath(
      check,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.04
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _DinoBrandPainter oldDelegate) {
    return oldDelegate.body != body ||
        oldDelegate.belly != belly ||
        oldDelegate.accent != accent ||
        oldDelegate.outline != outline ||
        oldDelegate.shield != shield ||
        oldDelegate.showShield != showShield;
  }
}

class ResistanceScoreCard extends StatelessWidget {
  const ResistanceScoreCard({required this.metrics, super.key});

  final ProcessingMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      color: scheme.primaryContainer.withValues(alpha: 0.58),
      child: Row(
        children: [
          MetricRing(
            value: metrics.aiResistanceScore,
            label: l10n.aiResistance,
            centerLabel: '${(metrics.aiResistanceScore * 100).round()}',
            color: scheme.primary,
            size: 92,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metrics.resistanceLevel(l10n),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.brandPromise,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.estimatedMetricsNote,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MetricRing extends StatelessWidget {
  const MetricRing({
    required this.value,
    required this.label,
    required this.centerLabel,
    this.size = 82,
    this.color,
    super.key,
  });

  final double value;
  final String label;
  final String centerLabel;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ringColor = color ?? scheme.primary;
    final normalized = value.clamp(0.0, 1.0).toDouble();

    return SizedBox(
      width: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: normalized),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: size,
                child: CustomPaint(
                  painter: _RingPainter(
                    value: animatedValue,
                    color: ringColor,
                    track: scheme.outlineVariant,
                  ),
                  child: Center(
                    child: Text(
                      centerLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.color,
    required this.track,
  });

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = math.max(5.0, size.shortestSide * 0.08);
    final rect = Offset.zero & size;
    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = track;
    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2, false, trackPaint);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.track != track;
  }
}

class ImageSurface extends StatelessWidget {
  const ImageSurface({
    required this.bytes,
    this.fit = BoxFit.contain,
    this.icon = Icons.image_outlined,
    super.key,
  });

  final Uint8List? bytes;
  final BoxFit fit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: bytes == null
            ? Center(
                child: Icon(icon, size: 44, color: scheme.onSurfaceVariant),
              )
            : Image.memory(
                bytes!,
                fit: fit,
                width: double.infinity,
                height: double.infinity,
                gaplessPlayback: true,
              ),
      ),
    );
  }
}

class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({
    required this.originalBytes,
    required this.processedBytes,
    required this.heatmapBytes,
    this.showHeatmap = false,
    super.key,
  });

  final Uint8List originalBytes;
  final Uint8List processedBytes;
  final Uint8List heatmapBytes;
  final bool showHeatmap;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _reveal = 0.5;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final handleLeft = constraints.maxWidth * _reveal;

              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageSurface(bytes: widget.originalBytes),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: _reveal,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ImageSurface(bytes: widget.processedBytes),
                              if (widget.showHeatmap)
                                IgnorePointer(
                                  child: Image.memory(
                                    widget.heatmapBytes,
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: double.infinity,
                                    gaplessPlayback: true,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (handleLeft - 1)
                          .clamp(0, constraints.maxWidth - 2)
                          .toDouble(),
                      top: 0,
                      bottom: 0,
                      child: Container(width: 2, color: scheme.primary),
                    ),
                    Positioned(
                      left: (handleLeft - 19)
                          .clamp(0, constraints.maxWidth - 38)
                          .toDouble(),
                      top: constraints.maxHeight / 2 - 19,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.drag_handle,
                          color: scheme.onPrimary,
                          size: 38,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _ImageLabel(
                        label: l10n.protected,
                        color: scheme.primary,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: _ImageLabel(
                        label: l10n.original,
                        color: scheme.secondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Slider(
          value: _reveal,
          min: 0,
          max: 1,
          onChanged: (value) {
            setState(() {
              _reveal = value;
            });
          },
        ),
      ],
    );
  }
}

class _ImageLabel extends StatelessWidget {
  const _ImageLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({required this.metrics, super.key});

  final ProcessingMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final values = <({String label, String value})>[
      (
        label: 'PSNR',
        value: metrics.psnr.isInfinite
            ? 'inf dB'
            : '${metrics.psnr.toStringAsFixed(1)} dB',
      ),
      (label: 'SSIM', value: metrics.ssim.toStringAsFixed(4)),
      (label: l10n.imageType, value: metrics.imageProfile.localizedLabel(l10n)),
      (
        label: l10n.textureComplexity,
        value: '${(metrics.textureComplexity * 100).toStringAsFixed(0)}%',
      ),
      (
        label: l10n.semanticCoverage,
        value: '${(metrics.semanticCoverage * 100).toStringAsFixed(0)}%',
      ),
      (
        label: l10n.featureDisruption,
        value: '${(metrics.featureDisruptionScore * 100).toStringAsFixed(0)}%',
      ),
      (
        label: l10n.embeddingInstability,
        value:
            '${(metrics.embeddingInstabilityEstimate * 100).toStringAsFixed(0)}%',
      ),
      (
        label: l10n.styleDisruption,
        value: '${(metrics.styleDisruptionEstimate * 100).toStringAsFixed(0)}%',
      ),
      (
        label: l10n.semanticConfusion,
        value:
            '${(metrics.semanticConfusionEstimate * 100).toStringAsFixed(0)}%',
      ),
      (
        label: l10n.reinterpretationResistance,
        value:
            '${(metrics.reinterpretationResistanceEstimate * 100).toStringAsFixed(0)}%',
      ),
      (
        label: l10n.imageFidelity,
        value: '${(metrics.imageFidelityEstimate * 100).toStringAsFixed(0)}%',
      ),
      (
        label: l10n.resistanceScore,
        value: '${(metrics.aiResistanceScore * 100).toStringAsFixed(0)}%',
      ),
      (
        label: l10n.metricTouched,
        value: '${(metrics.touchedPixelsRatio * 100).toStringAsFixed(1)}%',
      ),
      (
        label: l10n.metricPerturbation,
        value: '${(metrics.perturbationStrength * 100).toStringAsFixed(1)}%',
      ),
      (
        label: l10n.metricFrequency,
        value: '${(metrics.frequencyStrength * 100).toStringAsFixed(0)}%',
      ),
      (label: 'MAE', value: metrics.meanAbsoluteError.toStringAsFixed(2)),
      (
        label: l10n.watermarkFingerprint,
        value: metrics.watermarkFingerprint.substring(0, 8),
      ),
      (label: l10n.metricTime, value: '${metrics.elapsedMilliseconds} ms'),
      (label: l10n.metricSize, value: '${metrics.width}x${metrics.height}'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 3 : 2;
        final itemWidth = (constraints.maxWidth - (columns - 1) * 10) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in values)
              SizedBox(
                width: itemWidth,
                child: _MetricTile(label: item.label, value: item.value),
              ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusyOverlay extends StatelessWidget {
  const BusyOverlay({required this.stage, super.key});

  final ProcessingStage stage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    if (stage == ProcessingStage.idle) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.42),
        child: Center(
          child: AppCard(
            color: scheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DinoBrandMark(size: 58),
                const SizedBox(height: 14),
                Text(
                  stage == ProcessingStage.processing
                      ? l10n.scanProtecting
                      : stage.localizedLabel(l10n),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 220,
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
