class UserSettings {
  const UserSettings({
    required this.dailyLimit,
    required this.currencyCode,
    required this.displayName,
  });

  final double dailyLimit;
  final String currencyCode;
  final String displayName;

  factory UserSettings.defaults() => const UserSettings(
        dailyLimit: 2000,
        currencyCode: 'INR',
        displayName: 'SpendsLess',
      );

  UserSettings copyWith({
    double? dailyLimit,
    String? currencyCode,
    String? displayName,
  }) {
    return UserSettings(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      currencyCode: currencyCode ?? this.currencyCode,
      displayName: displayName ?? this.displayName,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyLimit': dailyLimit,
        'currencyCode': currencyCode,
        'displayName': displayName,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble() ?? 2000,
      currencyCode: (json['currencyCode'] as String?) ?? 'INR',
      displayName: (json['displayName'] as String?) ?? 'SpendsLess',
    );
  }
}