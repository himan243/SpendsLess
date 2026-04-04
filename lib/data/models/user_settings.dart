class UserSettings {
  const UserSettings({
    required this.dailyLimit,
    required this.currencyCode,
    required this.displayName,
    required this.avatarId,
  });

  final double dailyLimit;
  final String currencyCode;
  final String displayName;
  final String avatarId;

  factory UserSettings.defaults() => const UserSettings(
        dailyLimit: 2000,
        currencyCode: 'INR',
        displayName: 'SpendsLess',
        avatarId: 'spark',
      );

  UserSettings copyWith({
    double? dailyLimit,
    String? currencyCode,
    String? displayName,
    String? avatarId,
  }) {
    return UserSettings(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      currencyCode: currencyCode ?? this.currencyCode,
      displayName: displayName ?? this.displayName,
      avatarId: avatarId ?? this.avatarId,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyLimit': dailyLimit,
        'currencyCode': currencyCode,
        'displayName': displayName,
        'avatarId': avatarId,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble() ?? 2000,
      currencyCode: (json['currencyCode'] as String?) ?? 'INR',
      displayName: (json['displayName'] as String?) ?? 'SpendsLess',
      avatarId: (json['avatarId'] as String?) ?? 'spark',
    );
  }
}