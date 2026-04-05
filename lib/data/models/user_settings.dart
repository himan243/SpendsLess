enum LimitMode {
  daily,
  monthly,
}

class UserSettings {
  const UserSettings({
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.limitMode,
    required this.currencyCode,
    required this.displayName,
    required this.avatarId,
  });

  final double dailyLimit;
  final double monthlyLimit;
  final LimitMode limitMode;
  final String currencyCode;
  final String displayName;
  final String avatarId;

  factory UserSettings.defaults() => const UserSettings(
        dailyLimit: 2000,
        monthlyLimit: 60000,
        limitMode: LimitMode.daily,
        currencyCode: 'INR',
        displayName: 'SpendsLess',
        avatarId: 'spark',
      );

  UserSettings copyWith({
    double? dailyLimit,
    double? monthlyLimit,
    LimitMode? limitMode,
    String? currencyCode,
    String? displayName,
    String? avatarId,
  }) {
    return UserSettings(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      limitMode: limitMode ?? this.limitMode,
      currencyCode: currencyCode ?? this.currencyCode,
      displayName: displayName ?? this.displayName,
      avatarId: avatarId ?? this.avatarId,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyLimit': dailyLimit,
        'monthlyLimit': monthlyLimit,
        'limitMode': limitMode.toString().split('.').last,
        'currencyCode': currencyCode,
        'displayName': displayName,
        'avatarId': avatarId,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final modeStr = (json['limitMode'] as String?) ?? 'daily';
    final mode = modeStr == 'monthly' ? LimitMode.monthly : LimitMode.daily;
    return UserSettings(
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble() ?? 2000,
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 60000,
      limitMode: mode,
      currencyCode: (json['currencyCode'] as String?) ?? 'INR',
      displayName: (json['displayName'] as String?) ?? 'SpendsLess',
      avatarId: (json['avatarId'] as String?) ?? 'spark',
    );
  }
}