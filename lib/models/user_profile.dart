import 'package:flutter/material.dart';

class UserProfile {
  int? id;
  String name;
  String username;
  String email;
  String city;
  String bio;
  String avatarUrl;
  int tripsCount;
  double totalDistanceKm;
  int savedMountainsCount;

  UserProfile({
    this.id,
    required this.name,
    this.username = '',
    required this.email,
    required this.city,
    required this.bio,
    this.avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600&auto=format&fit=crop',
    this.tripsCount = 3,
    this.totalDistanceKm = 18.6,
    this.savedMountainsCount = 2,
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? city,
    String? bio,
    String? avatarUrl,
    int? tripsCount,
    double? totalDistanceKm,
    int? savedMountainsCount,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tripsCount: tripsCount ?? this.tripsCount,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      savedMountainsCount: savedMountainsCount ?? this.savedMountainsCount,
    );
  }
}

// Global notifier so profile data can be modified and reflected in real-time
class UserProfileNotifier extends ValueNotifier<UserProfile> {
  UserProfileNotifier()
      : super(
          UserProfile(
            id: 1,
            name: 'Alya Putri',
            username: 'alyaputri',
            email: 'alya.putri@email.com',
            city: 'Yogyakarta',
            bio: 'Pendaki pemula yang suka menikmati keindahan alam dan matahari terbit.',
            tripsCount: 3,
            totalDistanceKm: 18.6,
            savedMountainsCount: 2,
          ),
        );

  void updateProfile({
    int? id,
    String? name,
    String? username,
    String? email,
    String? city,
    String? bio,
    String? avatarUrl,
    int? tripsCount,
  }) {
    value = value.copyWith(
      id: id,
      name: name,
      username: username,
      email: email,
      city: city,
      bio: bio,
      avatarUrl: avatarUrl,
      tripsCount: tripsCount,
    );
  }
}

final userProfileNotifier = UserProfileNotifier();
