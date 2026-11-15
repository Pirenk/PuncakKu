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
    this.id = 1,
    this.name = 'Mirza',
    this.username = 'mirza',
    this.email = 'mirza@gmail.com',
    this.city = 'Yogyakarta',
    this.bio = 'Pendaki gunung & pecinta alam.',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
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

class UserProfileNotifier extends ValueNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile());

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

