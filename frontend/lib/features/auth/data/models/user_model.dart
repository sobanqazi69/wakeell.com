import 'package:equatable/equatable.dart';
import '../../../../core/utils/map_utils.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String? phone;
  final String? location;
  final String? jurisdiction;
  final bool isVerified;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.phone,
    this.location,
    this.jurisdiction,
    this.isVerified = false,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: handleNullableIntKey(json, 'id') ?? 0,
        name: handleNullableStringKey(json, 'name') ?? '',
        email: handleNullableStringKey(json, 'email') ?? '',
        role: handleNullableStringKey(json, 'role') ?? 'client',
        avatar: handleNullableStringKey(json, 'avatar'),
        phone: handleNullableStringKey(json, 'phone'),
        location: handleNullableStringKey(json, 'location'),
        jurisdiction: handleNullableStringKey(json, 'jurisdiction'),
        isVerified: handleNullableBoolKey(json, 'isVerified') ?? false,
        isActive: handleNullableBoolKey(json, 'isActive') ?? true,
      );
    } catch (_) {
      return const UserModel(id: 0, name: '', email: '', role: 'client');
    }
  }

  bool get isClient => role == 'client';
  bool get isLawyer => role == 'lawyer';
  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? name,
    String? avatar,
    String? phone,
    String? location,
    String? jurisdiction,
    bool? isVerified,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, avatar, isVerified, isActive];
}
