class AppUser {
  final String uid;
  final String email;
  final String? avatarUrl; // ⭐ THÊM AVATAR

  AppUser({
    required this.uid,
    required this.email,
    this.avatarUrl,
  });

  factory AppUser.fromMap(
    String uid,
    Map<String, dynamic> data,
  ) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}
