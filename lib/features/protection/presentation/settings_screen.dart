import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme_controller.dart';
import '../../../core/image_processing/image_processing_isolate.dart';
import '../../../l10n/l10n_extensions.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/protection_widgets.dart';
import '../application/protection_controller.dart';
import '../domain/protection_models.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _seedController;
  late final FocusNode _seedFocusNode;
  Timer? _previewTimer;
  Uint8List? _previewBytes;
  String? _previewKey;
  bool _isPreviewing = false;

  @override
  void initState() {
    super.initState();
    final seed = ref.read(protectionControllerProvider).settings.seed;
    _seedController = TextEditingController(text: seed.toString());
    _seedFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _seedController.dispose();
    _seedFocusNode.dispose();
    super.dispose();
  }

  void _commitSeed() {
    final l10n = context.l10n;
    final value = _seedController.text.trim();
    final parsed = int.tryParse(value);

    if (parsed == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.seedValidation),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    ref.read(protectionControllerProvider.notifier).setSeed(parsed);
    _seedFocusNode.unfocus();
  }

  void _maybeSchedulePreview(
    ProtectedImageRecord? activeRecord,
    ProcessingSettings settings,
  ) {
    final key = activeRecord == null
        ? 'empty'
        : '${activeRecord.outputPath}|'
              '${settings.mode.name}|${settings.seed}|${settings.lsbBits}|'
              '${settings.protectionStrength.toStringAsFixed(3)}|'
              '${settings.edgeSensitivity.toStringAsFixed(3)}|'
              '${settings.frequencyStrength.toStringAsFixed(3)}|'
              '${settings.faceWeight.toStringAsFixed(3)}|'
              '${settings.exportFormat.name}|${settings.jpegQuality}';

    if (_previewKey == key) {
      return;
    }

    _previewKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _schedulePreview(activeRecord, settings, key);
      }
    });
  }

  void _schedulePreview(
    ProtectedImageRecord? activeRecord,
    ProcessingSettings settings,
    String key,
  ) {
    _previewTimer?.cancel();

    if (activeRecord == null) {
      setState(() {
        _previewBytes = null;
        _isPreviewing = false;
      });
      return;
    }

    setState(() {
      _isPreviewing = true;
    });

    _previewTimer = Timer(const Duration(milliseconds: 420), () async {
      try {
        final result = await processImageOnWorker(
          AdversarialProcessRequest(
            bytes: activeRecord.originalBytes,
            settings: settings,
            previewMaxDimension: 360,
          ),
        );

        if (!mounted || _previewKey != key) {
          return;
        }

        setState(() {
          _previewBytes = result.bytes;
          _isPreviewing = false;
        });
      } on Object {
        if (!mounted || _previewKey != key) {
          return;
        }

        setState(() {
          _isPreviewing = false;
        });
      }
    });
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

    final l10n = context.l10n;
    final state = ref.watch(protectionControllerProvider);
    final controller = ref.read(protectionControllerProvider.notifier);
    final currentLocale = ref.watch(localeControllerProvider);
    final localeController = ref.read(localeControllerProvider.notifier);
    final currentTheme = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);
    final settings = state.settings;
    final seedText = settings.seed.toString();

    if (!_seedFocusNode.hasFocus && _seedController.text != seedText) {
      _seedController.text = seedText;
    }

    _maybeSchedulePreview(state.activeRecord, settings);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          TextButton.icon(
            onPressed: state.isBusy ? null : controller.resetSettings,
            icon: const Icon(Icons.restart_alt_outlined),
            label: Text(l10n.reset),
          ),
          TextButton.icon(
            onPressed: state.activeRecord == null || state.isBusy
                ? null
                : controller.reprocessActiveImage,
            icon: const Icon(Icons.autorenew_outlined),
            label: Text(l10n.apply),
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
                      AppCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              icon: Icons.translate_outlined,
                              title: l10n.language,
                            ),
                            const SizedBox(height: 12),
                            _SegmentSetting<String>(
                              label: l10n.language,
                              selected: currentLocale.languageCode,
                              segments: [
                                ButtonSegment<String>(
                                  value: 'en',
                                  icon: const Icon(Icons.language_outlined),
                                  label: Text(l10n.english),
                                ),
                                ButtonSegment<String>(
                                  value: 'ko',
                                  icon: const Icon(Icons.language_outlined),
                                  label: Text(l10n.korean),
                                ),
                              ],
                              onChanged: (value) {
                                localeController.setLocale(Locale(value));
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              icon: Icons.contrast_outlined,
                              title: l10n.theme,
                            ),
                            const SizedBox(height: 12),
                            _SegmentSetting<AppThemePreference>(
                              label: l10n.theme,
                              selected: currentTheme,
                              segments: [
                                ButtonSegment<AppThemePreference>(
                                  value: AppThemePreference.system,
                                  icon: const Icon(Icons.devices_outlined),
                                  label: Text(l10n.systemTheme),
                                ),
                                ButtonSegment<AppThemePreference>(
                                  value: AppThemePreference.light,
                                  icon: const Icon(Icons.light_mode_outlined),
                                  label: Text(l10n.lightTheme),
                                ),
                                ButtonSegment<AppThemePreference>(
                                  value: AppThemePreference.dark,
                                  icon: const Icon(Icons.dark_mode_outlined),
                                  label: Text(l10n.darkTheme),
                                ),
                              ],
                              onChanged: themeController.setTheme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              icon: Icons.preview_outlined,
                              title: l10n.livePreview,
                              trailing: _isPreviewing
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            AspectRatio(
                              aspectRatio: 16 / 10,
                              child: ImageSurface(
                                bytes:
                                    _previewBytes ??
                                    state.activeRecord?.processedBytes,
                                fit: BoxFit.contain,
                                icon: Icons.image_search_outlined,
                              ),
                            ),
                            if (state.activeRecord == null) ...[
                              const SizedBox(height: 10),
                              Text(
                                l10n.livePreviewEmpty,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              icon: Icons.shield_outlined,
                              title: l10n.protectionMode,
                            ),
                            const SizedBox(height: 12),
                            ProtectionModeSelector(
                              selected: settings.mode,
                              onChanged: controller.setProtectionMode,
                            ),
                            const SizedBox(height: 10),
                            ProtectionModeSummary(mode: settings.mode),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              icon: Icons.tag_outlined,
                              title: l10n.deterministicSeed,
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _seedController,
                              focusNode: _seedFocusNode,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    signed: true,
                                  ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _commitSeed(),
                              decoration: InputDecoration(
                                labelText: l10n.seed,
                                prefixIcon: const Icon(Icons.numbers_outlined),
                                suffixIcon: IconButton(
                                  tooltip: l10n.applySeed,
                                  onPressed: _commitSeed,
                                  icon: const Icon(Icons.check_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              icon: Icons.graphic_eq_outlined,
                              title: l10n.protectionControls,
                            ),
                            const SizedBox(height: 8),
                            _SliderSetting(
                              icon: Icons.shield_outlined,
                              label: l10n.protectionStrength,
                              description: l10n.protectionStrengthHelp,
                              value: settings.protectionStrength,
                              valueLabel:
                                  '${(settings.protectionStrength * 100).round()}%',
                              min: 0,
                              max: 1,
                              divisions: 20,
                              onChanged: controller.setProtectionStrength,
                            ),
                            _SliderSetting(
                              icon: Icons.blur_on_outlined,
                              label: l10n.edgeSensitivity,
                              description: l10n.edgeSensitivityHelp,
                              value: settings.edgeSensitivity,
                              valueLabel:
                                  '${(settings.edgeSensitivity * 100).round()}%',
                              min: 0,
                              max: 1,
                              divisions: 20,
                              onChanged: controller.setEdgeSensitivity,
                            ),
                            _SliderSetting(
                              icon: Icons.grid_4x4_outlined,
                              label: l10n.frequencyStrength,
                              description: l10n.frequencyStrengthHelp,
                              value: settings.frequencyStrength,
                              valueLabel:
                                  '${(settings.frequencyStrength * 100).round()}%',
                              min: 0,
                              max: 1,
                              divisions: 20,
                              onChanged: controller.setFrequencyStrength,
                            ),
                            _SliderSetting(
                              icon: Icons.face_retouching_natural_outlined,
                              label: l10n.faceWeighting,
                              description: l10n.faceWeightingHelp,
                              value: settings.faceWeight,
                              valueLabel:
                                  '${(settings.faceWeight * 100).round()}%',
                              min: 0,
                              max: 1,
                              divisions: 20,
                              onChanged: controller.setFaceWeight,
                            ),
                            const SizedBox(height: 8),
                            _SegmentSetting<int>(
                              label: l10n.rgbLsbDepth,
                              selected: settings.lsbBits,
                              segments: [
                                ButtonSegment<int>(
                                  value: 1,
                                  icon: const Icon(Icons.looks_one_outlined),
                                  label: Text(l10n.oneBit),
                                ),
                                ButtonSegment<int>(
                                  value: 2,
                                  icon: const Icon(Icons.looks_two_outlined),
                                  label: Text(l10n.twoBits),
                                ),
                              ],
                              onChanged: controller.setLsbBits,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              icon: Icons.save_alt_outlined,
                              title: l10n.export,
                            ),
                            const SizedBox(height: 14),
                            _SegmentSetting<ExportFormat>(
                              label: l10n.format,
                              selected: settings.exportFormat,
                              segments: const [
                                ButtonSegment<ExportFormat>(
                                  value: ExportFormat.png,
                                  icon: Icon(Icons.image_outlined),
                                  label: Text('PNG'),
                                ),
                                ButtonSegment<ExportFormat>(
                                  value: ExportFormat.jpeg,
                                  icon: Icon(Icons.photo_outlined),
                                  label: Text('JPEG'),
                                ),
                              ],
                              onChanged: controller.setExportFormat,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: settings.exportFormat == ExportFormat.jpeg
                                  ? Padding(
                                      key: const ValueKey('jpeg-quality'),
                                      padding: const EdgeInsets.only(top: 8),
                                      child: _SliderSetting(
                                        icon: Icons.high_quality_outlined,
                                        label: l10n.jpegQuality,
                                        description: l10n.jpegQualityHelp,
                                        value: settings.jpegQuality.toDouble(),
                                        valueLabel: settings.jpegQuality
                                            .toString(),
                                        min: 70,
                                        max: 100,
                                        divisions: 30,
                                        onChanged: (value) {
                                          controller.setJpegQuality(
                                            value.round(),
                                          );
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('png-quality'),
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

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.valueLabel,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String description;
  final double value;
  final String valueLabel;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Text(
                      valueLabel,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: description,
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: valueLabel,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentSetting<T extends Object> extends StatelessWidget {
  const _SegmentSetting({
    required this.label,
    required this.selected,
    required this.segments,
    required this.onChanged,
  });

  final String label;
  final T selected;
  final List<ButtonSegment<T>> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: constraints.maxWidth,
              child: SegmentedButton<T>(
                segments: segments,
                selected: <T>{selected},
                onSelectionChanged: (values) => onChanged(values.first),
              ),
            ),
          ],
        );
      },
    );
  }
}
