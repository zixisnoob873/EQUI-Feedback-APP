import 'package:flutter/material.dart';
import '../models/field_config.dart';
import '../theme/app_theme.dart';

class DynamicFormField extends StatelessWidget {
  final FieldConfig config;
  final TextEditingController? controller;
  final String? dropdownValue;
  final ValueChanged<String?>? onDropdownChanged;
  final String? Function(String?)? validator;

  const DynamicFormField({
    super.key,
    required this.config,
    this.controller,
    this.dropdownValue,
    this.onDropdownChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: _buildField(),
      ),
    );
  }

  Widget _buildField() {
    switch (config.fieldType) {
      case FieldType.text:
        return _buildTextField();
      case FieldType.number:
        return _buildNumberField();
      case FieldType.dropdown:
        return _buildDropdownField();
    }
  }

  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        config.label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        Focus(
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter ${config.label.toLowerCase()}...',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        Focus(
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter ${config.label.toLowerCase()}...',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        Focus(
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: DropdownButtonFormField<String>(
                  value: dropdownValue,
                  onChanged: onDropdownChanged,
                  validator: validator,
                  items: config.options
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(
                              option,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    hintText: 'Select ${config.label.toLowerCase()}...',
                    suffixIcon: const Icon(
                      Icons.expand_more,
                      color: AppColors.goldDark,
                    ),
                  ),
                  dropdownColor: AppColors.inputFill,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
