import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum FieldType {
  text,
  dropdown,
  number;

  String get label {
    switch (this) {
      case FieldType.text:
        return 'Text';
      case FieldType.dropdown:
        return 'Dropdown';
      case FieldType.number:
        return 'Number';
    }
  }

  static FieldType fromString(String value) {
    return FieldType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FieldType.text,
    );
  }
}

class FieldConfig {
  final String id;
  String label;
  FieldType fieldType;
  List<String> options;
  bool active;
  int order;

  FieldConfig({
    String? id,
    required this.label,
    this.fieldType = FieldType.text,
    List<String>? options,
    this.active = true,
    this.order = 0,
  })  : id = id ?? _uuid.v4(),
        options = options ?? [];

  FieldConfig copyWith({
    String? label,
    FieldType? fieldType,
    List<String>? options,
    bool? active,
    int? order,
  }) {
    return FieldConfig(
      id: id,
      label: label ?? this.label,
      fieldType: fieldType ?? this.fieldType,
      options: options ?? List.from(this.options),
      active: active ?? this.active,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'fieldType': fieldType.name,
        'options': options,
        'active': active,
        'order': order,
      };

  factory FieldConfig.fromJson(Map<String, dynamic> json) => FieldConfig(
        id: json['id'] as String,
        label: json['label'] as String,
        fieldType: FieldType.fromString(json['fieldType'] as String),
        options: (json['options'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        active: json['active'] as bool? ?? true,
        order: json['order'] as int? ?? 0,
      );

  static List<FieldConfig> defaults() => [
        FieldConfig(
          label: 'Tier',
          fieldType: FieldType.dropdown,
          options: [
            'Bronze',
            'Silver',
            'Gold',
            'Platinum',
            'Diamond',
            'Immortal 1',
            'Immortal 2',
            'Immortal 3',
            'Radiant',
          ],
          order: 0,
        ),
        FieldConfig(
          label: 'Duration',
          fieldType: FieldType.dropdown,
          options: ['15 min', '30 min', '1 hour', '2 hours', '3+ hours'],
          order: 1,
        ),
        FieldConfig(
          label: 'Game',
          fieldType: FieldType.text,
          order: 2,
        ),
        FieldConfig(
          label: 'Name',
          fieldType: FieldType.text,
          order: 3,
        ),
        FieldConfig(
          label: 'Issue',
          fieldType: FieldType.dropdown,
          options: [
            'Hardware',
            'Connectivity',
            'Pricing',
            'Staff',
            'Cleanliness',
            'Other',
          ],
          order: 4,
        ),
        FieldConfig(
          label: 'Suggestions',
          fieldType: FieldType.text,
          order: 5,
        ),
      ];
}
