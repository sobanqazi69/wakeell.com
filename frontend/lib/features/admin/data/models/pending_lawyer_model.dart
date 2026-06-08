import 'package:equatable/equatable.dart';
import '../../../../../core/utils/map_utils.dart';

class PendingLawyerModel extends Equatable {
  final int id;
  final int userId;
  final String barLicense;
  final String status;
  final String? adminNote;
  final double rating;
  final int reviewCount;
  final String createdAt;
  // nested user
  final String userName;
  final String userEmail;
  final String? userPhone;

  const PendingLawyerModel({
    required this.id,
    required this.userId,
    required this.barLicense,
    required this.status,
    this.adminNote,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.userName,
    required this.userEmail,
    this.userPhone,
  });

  factory PendingLawyerModel.fromJson(Map<String, dynamic> json) {
    try {
      final user = handleNullableMapKey(json, 'user') ?? {};
      return PendingLawyerModel(
        id:          handleNullableIntKey(json, 'id') ?? 0,
        userId:      handleNullableIntKey(json, 'userId') ?? 0,
        barLicense:  handleNullableStringKey(json, 'barLicense') ?? '',
        status:      handleNullableStringKey(json, 'status') ?? 'pending',
        adminNote:   handleNullableStringKey(json, 'adminNote'),
        rating:      (handleNullableStringKey(json, 'rating') != null
            ? double.tryParse(handleNullableStringKey(json, 'rating')!) ?? 0.0
            : 0.0),
        reviewCount: handleNullableIntKey(json, 'reviewCount') ?? 0,
        createdAt:   handleNullableStringKey(json, 'createdAt') ?? '',
        userName:    handleNullableStringKey(user, 'name') ?? '',
        userEmail:   handleNullableStringKey(user, 'email') ?? '',
        userPhone:   handleNullableStringKey(user, 'phone'),
      );
    } catch (_) {
      return const PendingLawyerModel(
        id: 0, userId: 0, barLicense: '', status: 'pending',
        rating: 0, reviewCount: 0, createdAt: '',
        userName: '', userEmail: '',
      );
    }
  }

  String get initials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  String get appliedDate {
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  @override
  List<Object?> get props => [id, userId, barLicense, status, adminNote, createdAt];
}

class AdminStatsModel extends Equatable {
  final int totalUsers;
  final int totalClients;
  final int totalLawyers;
  final int pendingLawyers;
  final int approvedLawyers;
  final int rejectedLawyers;

  const AdminStatsModel({
    required this.totalUsers,
    required this.totalClients,
    required this.totalLawyers,
    required this.pendingLawyers,
    required this.approvedLawyers,
    required this.rejectedLawyers,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      return AdminStatsModel(
        totalUsers:      handleNullableIntKey(json, 'totalUsers') ?? 0,
        totalClients:    handleNullableIntKey(json, 'totalClients') ?? 0,
        totalLawyers:    handleNullableIntKey(json, 'totalLawyers') ?? 0,
        pendingLawyers:  handleNullableIntKey(json, 'pendingLawyers') ?? 0,
        approvedLawyers: handleNullableIntKey(json, 'approvedLawyers') ?? 0,
        rejectedLawyers: handleNullableIntKey(json, 'rejectedLawyers') ?? 0,
      );
    } catch (_) {
      return const AdminStatsModel(
        totalUsers: 0, totalClients: 0, totalLawyers: 0,
        pendingLawyers: 0, approvedLawyers: 0, rejectedLawyers: 0,
      );
    }
  }

  @override
  List<Object?> get props => [totalUsers, pendingLawyers, approvedLawyers];
}
