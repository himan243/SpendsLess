import 'package:intl/intl.dart';

final _rupeeFormatter = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

extension RupeeFormatting on num {
  String get inRupees => _rupeeFormatter.format(this);
}