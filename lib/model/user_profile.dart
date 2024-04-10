
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String avatar;
  final String bio;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.bio,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user_id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
      bio: json['bio'],
    );
  }
}