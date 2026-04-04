enum PaymentMethod {
  upi,
  card,
  cash,
}

extension PaymentMethodMeta on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.upi => 'UPI',
        PaymentMethod.card => 'Card',
        PaymentMethod.cash => 'Cash',
      };

  String get emoji => switch (this) {
        PaymentMethod.upi => '📲',
        PaymentMethod.card => '💳',
        PaymentMethod.cash => '💵',
      };

  String get description => switch (this) {
        PaymentMethod.upi => 'GPay, PhonePe, Paytm',
        PaymentMethod.card => 'Debit or credit',
        PaymentMethod.cash => 'Physical cash',
      };
}

const allPaymentMethods = PaymentMethod.values;