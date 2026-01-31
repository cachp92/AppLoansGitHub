

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

  Loan({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.principal,
    required this.annualRate,
    required this.termMonths,
    required this.startDate,
  });

  double get monthlyRate => annualRate / 100 / 12;

  // Estimated monthly payment (simple logic, AmortizationService has detailed table)
  // PMT = P * r * (1+r)^n / ((1+r)^n - 1)
  double get estimatedMonthlyPayment {
    if (annualRate == 0) return principal / termMonths;



    // Dart 3.0 has pow inside dart:math.
    return 0.0; // Placeholder, logic moved to service for clean separation, or we can implement basic here.
  }
}
