import 'package:equatable/equatable.dart';
import '../../../../../core/utils/map_utils.dart';

class LawyerModel extends Equatable {
  final int id;
  final int userId;
  final String barLicense;
  final List<String> specializations;
  final String bio;
  final List<String> languages;
  final double hourlyRate;
  final String currency;
  final int experience;
  final double rating;
  final int reviewCount;
  final String status;
  // nested user
  final String name;
  final String? avatar;
  final String? location;
  final String? jurisdiction;
  final String? phone;

  const LawyerModel({
    required this.id,
    required this.userId,
    required this.barLicense,
    required this.specializations,
    required this.bio,
    required this.languages,
    required this.hourlyRate,
    required this.currency,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.status,
    required this.name,
    this.avatar,
    this.location,
    this.jurisdiction,
    this.phone,
  });

  factory LawyerModel.fromJson(Map<String, dynamic> json) {
    try {
      final user = handleNullableMapKey(json, 'user') ?? {};
      return LawyerModel(
        id:              handleNullableIntKey(json, 'id') ?? 0,
        userId:          handleNullableIntKey(json, 'userId') ?? 0,
        barLicense:      handleNullableStringKey(json, 'barLicense') ?? '',
        specializations: (handleNullableListKey(json, 'specializations') ?? []).cast<String>(),
        bio:             handleNullableStringKey(json, 'bio') ?? '',
        languages:       (handleNullableListKey(json, 'languages') ?? []).cast<String>(),
        hourlyRate:      double.tryParse('${json['hourlyRate'] ?? 0}') ?? 0,
        currency:        handleNullableStringKey(json, 'currency') ?? 'PKR',
        experience:      handleNullableIntKey(json, 'experience') ?? 0,
        rating:          double.tryParse('${json['rating'] ?? 0}') ?? 0,
        reviewCount:     handleNullableIntKey(json, 'reviewCount') ?? 0,
        status:          handleNullableStringKey(json, 'status') ?? 'pending',
        name:            handleNullableStringKey(user, 'name') ?? '',
        avatar:          handleNullableStringKey(user, 'avatar'),
        location:        handleNullableStringKey(user, 'location'),
        jurisdiction:    handleNullableStringKey(user, 'jurisdiction'),
        phone:           handleNullableStringKey(user, 'phone'),
      );
    } catch (_) {
      return const LawyerModel(
        id: 0, userId: 0, barLicense: '', specializations: [], bio: '',
        languages: [], hourlyRate: 0, currency: 'PKR', experience: 0,
        rating: 0, reviewCount: 0, status: 'approved', name: '',
      );
    }
  }

  LawyerModel copyWith({String? avatar}) => LawyerModel(
    id: id, userId: userId, barLicense: barLicense, specializations: specializations,
    bio: bio, languages: languages, hourlyRate: hourlyRate, currency: currency,
    experience: experience, rating: rating, reviewCount: reviewCount, status: status,
    name: name, avatar: avatar, location: location, jurisdiction: jurisdiction, phone: phone,
  );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  String get formattedRate => hourlyRate == 0 ? 'Free' : 'PKR ${hourlyRate.toStringAsFixed(0)}';

  String get ratingDisplay => rating == 0 ? '—' : rating.toStringAsFixed(1);

  @override
  List<Object?> get props => [id, userId, name, status];
}
