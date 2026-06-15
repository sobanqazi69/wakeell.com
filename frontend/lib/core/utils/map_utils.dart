import 'dart:convert';

String? handleNullableStringKey(Map<String, dynamic> json, String key) {
  final val = json[key];
  if (val == null) return null;
  return val.toString();
}

int? handleNullableIntKey(Map<String, dynamic> json, String key) {
  final val = json[key];
  if (val == null) return null;
  if (val is int) return val;
  return int.tryParse(val.toString());
}

double? handleNullableDoubleKey(Map<String, dynamic> json, String key) {
  final val = json[key];
  if (val == null) return null;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  return double.tryParse(val.toString());
}

bool? handleNullableBoolKey(Map<String, dynamic> json, String key) {
  final val = json[key];
  if (val == null) return null;
  if (val is bool) return val;
  return val.toString().toLowerCase() == 'true';
}

List? handleNullableListKey(Map<String, dynamic> json, String key) {
  final val = json[key];
  if (val == null) return null;
  if (val is List) return val;
  // MySQL JSON columns sometimes return a pre-encoded string instead of a
  // parsed array — happens when data was stored via a non-Sequelize path
  // or when the column type is TEXT rather than JSON.
  if (val is String && val.length > 1 && val.startsWith('[')) {
    try {
      final parsed = jsonDecode(val);
      if (parsed is List) return parsed;
    } catch (_) {}
  }
  return null;
}

Map<String, dynamic>? handleNullableMapKey(Map<String, dynamic> json, String key) {
  final val = json[key];
  if (val == null) return null;
  if (val is Map<String, dynamic>) return val;
  return null;
}
