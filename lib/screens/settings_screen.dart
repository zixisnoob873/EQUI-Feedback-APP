import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/field_config.dart';
import '../providers/field_config_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gold_button.dart';
import '../widgets/press_scale.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(fieldConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONTROL PANEL'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: fields.isEmpty
                ? _buildEmptyFields()
                : _buildFieldList(fields),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          const Text(
            'MANAGE FIELDS',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          Text(
            '${ref.watch(fieldConfigProvider).length} fields',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFields() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.list_alt, size: 48,
              color: AppColors.gold.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          const Text(
            'No fields configured',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldList(List<FieldConfig> fields) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: fields.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(fieldConfigProvider.notifier).reorder(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final field = fields[index];
        return _buildFieldItem(field, index);
      },
    );
  }

  Widget _buildFieldItem(FieldConfig field, int index) {
    return AnimatedSize(
      key: ValueKey(field.id),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: field.active ? AppColors.goldDark : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.drag_handle,
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.label,
                        style: TextStyle(
                          color: field.active
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        field.fieldType.label,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildToggle(field),
                const SizedBox(width: 4),
                PressScale(
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: AppColors.goldDark,
                    onPressed: () => _showFieldDialog(field: field),
                  ),
                ),
                PressScale(
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: AppColors.crimson,
                    onPressed: () => _confirmDelete(field),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(FieldConfig field) {
    return SizedBox(
      width: 44,
      height: 28,
      child: Switch.adaptive(
        value: field.active,
        activeColor: AppColors.gold,
        activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
        inactiveThumbColor: AppColors.textMuted,
        inactiveTrackColor: AppColors.border,
        onChanged: (_) {
          ref.read(fieldConfigProvider.notifier).toggleActive(field.id);
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: GoldButton(
        label: 'ADD FIELD',
        icon: Icons.add_rounded,
        onPressed: () => _showFieldDialog(),
      ),
    );
  }

  void _showFieldDialog({FieldConfig? field}) {
    final isEditing = field != null;
    final labelController =
        TextEditingController(text: isEditing ? field.label : '');
    var selectedType = isEditing ? field.fieldType : FieldType.text;
    final optionsController = TextEditingController(
      text: isEditing ? field.options.join(', ') : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        side: BorderSide(color: AppColors.goldDark, width: 0.5),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? 'EDIT FIELD' : 'ADD FIELD',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'Field Label',
                      hintText: 'e.g. Game, Tier, Score...',
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<FieldType>(
                    value: selectedType,
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => selectedType = val);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Field Type',
                    ),
                    items: FieldType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ))
                        .toList(),
                    dropdownColor: AppColors.inputFill,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  if (selectedType == FieldType.dropdown) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: optionsController,
                      decoration: const InputDecoration(
                        labelText: 'Options (comma-separated)',
                        hintText: 'Bronze, Silver, Gold...',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                  const SizedBox(height: 24),
                  GoldButton(
                    label: isEditing ? 'SAVE CHANGES' : 'CREATE FIELD',
                    onPressed: () {
                      final label = labelController.text.trim();
                      if (label.isEmpty) return;

                      final options = selectedType == FieldType.dropdown
                          ? optionsController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList()
                          : <String>[];

                      if (isEditing) {
                        ref
                            .read(fieldConfigProvider.notifier)
                            .updateField(field.copyWith(
                              label: label,
                              fieldType: selectedType,
                              options: options,
                            ));
                      } else {
                        ref
                            .read(fieldConfigProvider.notifier)
                            .addField(
                              label: label,
                              fieldType: selectedType,
                              options: options,
                            );
                      }
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(FieldConfig field) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Field'),
        content: Text(
          'Remove "${field.label}" from all forms?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(fieldConfigProvider.notifier)
                  .deleteField(field.id);
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: AppColors.crimson),
            ),
          ),
        ],
      ),
    );
  }
}
