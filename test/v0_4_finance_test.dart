import 'package:flutter_test/flutter_test.dart';
import 'package:app_loans_ag/models/loan.dart';
import 'package:app_loans_ag/models/extra_payment.dart';
import 'package:app_loans_ag/services/amortization_service.dart';
import 'package:app_loans_ag/repositories/loan_repository.dart';

void main() {
  final service = AmortizationService();
  final repo = LoanRepository(service);

  test('v0.4 Logic - Demo Data Seeding', () {
    // Should start with 4 demo loans
    expect(repo.loans.length, 4);
    expect(repo.loans.any((l) => l.name == 'Personal Loan'), true);
  });

  test('v0.4 Logic - Extra Payment Reduces Term & Interest', () {
    final loan = Loan(
      name: 'Test Loan',
      type: LoanType.personal,
      currency: Currency.usd,
      principal: 100000,
      annualRate: 10,
      termMonths: 120, // 10 years
      startDate: DateTime.now(),
    );

    // Baseline
    final baseSchedule = service.calculateAmortization(loan);
    final baseInterest = baseSchedule.fold(0.0, (sum, row) => sum + row.interest);
    final baseTerm = baseSchedule.length;

    // With Extra Payment
    final extraLoan = loan.copyWith(
      extraPayments: [
        ExtraPayment(period: 1, amount: 10000) // Big chunk at start
      ]
    );

    final extraSchedule = service.calculateWithExtras(extraLoan);
    final extraInterest = extraSchedule.fold(0.0, (sum, row) => sum + row.interest);
    final extraTerm = extraSchedule.length;

    print('Base Int: $baseInterest, Extra Int: $extraInterest');
    print('Base Term: $baseTerm, Extra Term: $extraTerm');

    expect(extraInterest, lessThan(baseInterest), reason: 'Interest should be lower');
    expect(extraTerm, lessThan(baseTerm), reason: 'Term should be shortened');
  });
}
