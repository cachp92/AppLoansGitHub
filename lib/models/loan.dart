

import 'dart:math';
import 'extra_payment.dart';

enum LoanType {
  personal,
  hipotecario,
  auto,
  creditCard,
}

extension LoanTypeExtension on LoanType {
  String get label {
    switch (this) {
      case LoanType.personal: return 'Personal';
      case LoanType.hipotecario: return 'Mortgage';
      case LoanType.auto: return 'Auto';
      case LoanType.creditCard: return 'Credit Card';
    }
  }
}

enum Currency {
  mxn,
  usd,
  eur,
}

extension CurrencyExtension on Currency {
  String get label {
    switch (this) {
      case Currency.mxn: return 'MXN';
      case Currency.usd: return 'USD';
      case Currency.eur: return 'EUR';
    }
  }
}

class Loan {
  final String id;
  final String name;
  final LoanType type;
  final Currency currency;
  final double principal; // Monto prestado
  final double annualRate; // Tasa anual %
  final int termMonths; // Plazo en meses
  final DateTime startDate;
  final List<ExtraPayment> extraPayments;

  Loan({
    String? id,
    required this.name,
    required this.type,
    required this.currency,
    required this.principal,
    required this.annualRate,
    required this.termMonths,
    required this.startDate,
    this.extraPayments = const [],
  }) : id = id ?? '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';

  double get monthlyRate => annualRate / 100 / 12;

  // Estimated monthly payment (simple logic, AmortizationService has detailed table)
  // PMT = P * r * (1+r)^n / ((1+r)^n - 1)
  double get estimatedMonthlyPayment {
    if (annualRate == 0) return principal / termMonths;



    // Dart 3.0 has pow inside dart:math.
  // Placeholder, logic moved to service for clean separation, or we can implement basic here.
    return 0.0; 
  }

  Loan copyWith({
    String? name,
    LoanType? type,
    Currency? currency,
    double? principal,
    double? annualRate,
    int? termMonths,
    DateTime? startDate,
    List<ExtraPayment>? extraPayments,
  }) {
    return Loan(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      principal: principal ?? this.principal,
      annualRate: annualRate ?? this.annualRate,
      termMonths: termMonths ?? this.termMonths,
      startDate: startDate ?? this.startDate,
      extraPayments: extraPayments ?? this.extraPayments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name, // Use simple name or custom string
      'currency': currency.name,
      'principal': principal,
      'annualRate': annualRate,
      'termMonths': termMonths,
      'startDate': startDate.toIso8601String(), // Storing as ISO string is easier for JSON, but Firestore prefers Timestamp. 
      // Requirement allows "timestamp or ISO string". ISO is easier to debug in console.
      'extraPayments': extraPayments.map((e) => e.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map, {String? id}) {
    // Handle Date Parsing (Timestamp or String)
    DateTime parseDate(dynamic val) {
      if (val is String) return DateTime.parse(val);
      // if (val is Timestamp) return val.toDate(); // If we import cloud_firestore
      // To avoid model depending on cloud_firestore directly if possible, we can just assume String for now 
      // OR rely on the Repository to convert Timestamp to DateTime before creating Loan?
      // No, Repository typically passes map.
      // Let's rely on ISO Strings for this MVP to keep Model Clean? 
      // But Console edits might create Timestamps.
      // Use dynamic check.
       if (val != null && val.runtimeType.toString() == 'Timestamp') {
          return (val as dynamic).toDate();
       }
      return DateTime.now(); 
    }

    return Loan(
      id: id ?? map['id'],
      name: map['name'] ?? '',
      type: LoanType.values.firstWhere((e) => e.name == map['type'], orElse: () => LoanType.personal),
      currency: Currency.values.firstWhere((e) => e.name == map['currency'], orElse: () => Currency.mxn),
      principal: (map['principal'] as num?)?.toDouble() ?? 0.0,
      annualRate: (map['annualRate'] as num?)?.toDouble() ?? 0.0,
      termMonths: (map['termMonths'] as num?)?.toInt() ?? 12,
      startDate: parseDate(map['startDate']),
      extraPayments: (map['extraPayments'] as List<dynamic>?)
              ?.map((e) => ExtraPayment.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
