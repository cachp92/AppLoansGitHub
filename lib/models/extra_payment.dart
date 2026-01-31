class ExtraPayment {
  final int period; // Month index (1-based)
  final double amount;

  ExtraPayment({required this.period, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'period': period,
      'amount': amount,
    };
  }

  factory ExtraPayment.fromMap(Map<String, dynamic> map) {
    return ExtraPayment(
      period: map['period'] as int,
      amount: (map['amount'] as num).toDouble(),
    );
  }
}
