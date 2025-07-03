class AppUser {
  final String uid;
  final String username;
  final int coins;
  final int xp;
  final int level;
  final bool onboardingComplete;

  AppUser({
    required this.uid,
    required this.username,
    required this.coins,
    required this.xp,
    required this.level,
    required this.onboardingComplete,
  });

  AppUser copyWith(
      {String? username,
      int? coins,
      int? xp,
      int? level,
      bool? onboardingComplete}) {
    return AppUser(
      uid: uid,
      username: username ?? this.username,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'],
        username: json['username'],
        coins: json['coins'],
        xp: json['xp'],
        level: json['level'],
        onboardingComplete: json['onboardingComplete'],
      );
}
