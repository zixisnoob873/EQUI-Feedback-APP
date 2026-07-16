import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_config.dart';
import '../providers/field_config_provider.dart';
import '../providers/feedback_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dynamic_form_field.dart';
import '../widgets/gold_button.dart';
import '../widgets/press_scale.dart';
import '../widgets/pulse_animation.dart';

class DataEntryScreen extends ConsumerStatefulWidget {
  const DataEntryScreen({super.key});

  @override
  ConsumerState<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends ConsumerState<DataEntryScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _dropdownValues = {};
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _rebuildControllers(List<FieldConfig> fields) {
    for (final field in fields) {
      _controllers.putIfAbsent(field.id, () => TextEditingController());
      _dropdownValues.putIfAbsent(field.id, () => null);
    }
    final ids = fields.map((f) => f.id).toSet();
    _controllers.keys
        .where((id) => !ids.contains(id))
        .toList()
        .forEach((id) {
      _controllers[id]?.dispose();
      _controllers.remove(id);
      _dropdownValues.remove(id);
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final fields = ref.read(activeFieldConfigsProvider);
    final payload = <String, dynamic>{};

    for (final field in fields) {
      switch (field.fieldType) {
        case FieldType.text:
        case FieldType.number:
          final value = _controllers[field.id]?.text.trim() ?? '';
          if (value.isNotEmpty) {
            payload[field.label] = field.fieldType == FieldType.number
                ? num.tryParse(value) ?? value
                : value;
          }
          break;
        case FieldType.dropdown:
          final value = _dropdownValues[field.id];
          if (value != null && value.isNotEmpty) {
            payload[field.label] = value;
          }
          break;
      }
    }

    final success = await ref.read(feedbackProvider.notifier).submitFeedback(payload);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      setState(() => _showSuccess = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            for (final c in _controllers.values) {
              c.clear();
            }
            for (final k in _dropdownValues.keys) {
              _dropdownValues[k] = null;
            }
          });
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 20),
              SizedBox(width: 12),
              Text('Failed to submit. Check connection.'),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(activeFieldConfigsProvider);
    _rebuildControllers(fields);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FEEDBACK ENTRY'),
        actions: [
          PressScale(
            child: IconButton(
              icon: const Icon(Icons.dashboard_customize, color: AppColors.gold),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildFormBody(fields),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.goldDark, width: 0.5),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 14, color: AppColors.gold),
              SizedBox(width: 8),
              Text(
                'All fields are optional',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormBody(List<FieldConfig> fields) {
    if (fields.isEmpty) {
      return Container(
        key: const ValueKey('empty'),
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.tune, size: 48, color: AppColors.gold.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'No active form fields',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              child: const Text('CONFIGURE FIELDS'),
            ),
          ],
        ),
      );
    }

    return Column(
      key: ValueKey(fields.length),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...fields.map((field) => DynamicFormField(
              key: ValueKey(field.id),
              config: field,
              controller: _controllers[field.id],
              dropdownValue: _dropdownValues[field.id],
              onDropdownChanged: (val) {
                setState(() => _dropdownValues[field.id] = val);
              },
            )),
        const SizedBox(height: 8),
        _buildSubmitSection(),
      ],
    );
  }

  Widget _buildSubmitSection() {
    if (_showSuccess) {
      return const GoldRadarPulse(
        child: GoldButton(
          label: 'SUBMITTED',
          icon: Icons.check_circle,
          isLoading: false,
        ),
      );
    }

    return GoldButton(
      label: 'SUBMIT FEEDBACK',
      icon: Icons.send_rounded,
      isLoading: _isSubmitting,
      onPressed: _submit,
    );
  }
}
