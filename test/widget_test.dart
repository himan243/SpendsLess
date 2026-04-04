import 'package:flutter_test/flutter_test.dart';
import 'package:spendsless/core/extensions/num_ext.dart';

void main() {
  test('formats values in INR', () {
    expect(12345.inRupees, '₹12,345');
    expect(2000.inRupees, '₹2,000');
  });
}
