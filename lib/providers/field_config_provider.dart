import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/field_config.dart';

const _prefsKey = 'field_configs';
const _uuid = Uuid();

class FieldConfigNotifier extends StateNotifier<List<FieldConfig>> {
  FieldConfigNotifier() : super([]);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json != null && json.isNotEmpty) {
      final list = (jsonDecode(json) as List)
          .map((e) => FieldConfig.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      state = list;
    } else {
      state = FieldConfig.defaults();
      await _persist();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((f) => f.toJson()).toList());
    await prefs.setString(_prefsKey, json);
  }

  Future<void> addField({
    required String label,
    required FieldType fieldType,
    List<String>? options,
  }) async {
    state = [
      ...state,
      FieldConfig(
        id: _uuid.v4(),
        label: label,
        fieldType: fieldType,
        options: options ?? [],
        active: true,
        order: state.length,
      ),
    ];
    await _persist();
  }

  Future<void> updateField(FieldConfig updated) async {
    state = state.map((f) => f.id == updated.id ? updated : f).toList();
    await _persist();
  }

  Future<void> deleteField(String id) async {
    state = state.where((f) => f.id != id).toList();
    await _persist();
  }

  Future<void> toggleActive(String id) async {
    state = state.map((f) {
      if (f.id == id) {
        return f.copyWith(active: !f.active);
      }
      return f;
    }).toList();
    await _persist();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(order: i);
    }
    state = list;
    await _persist();
  }

  List<FieldConfig> get activeFields =>
      state.where((f) => f.active).toList()..sort((a, b) => a.order.compareTo(b.order));
}

final fieldConfigProvider =
    StateNotifierProvider<FieldConfigNotifier, List<FieldConfig>>((ref) {
  return FieldConfigNotifier();
});

final activeFieldConfigsProvider = Provider<List<FieldConfig>>((ref) {
  return ref.watch(fieldConfigProvider)
      .where((f) => f.active)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
});
