import 'package:flutter_test/flutter_test.dart';
import 'package:app_loans_ag/models/loan.dart';
import 'package:app_loans_ag/services/amortization_service.dart';
import 'package:app_loans_ag/repositories/loan_repository.dart';

void main() {
  final service = AmortizationService();
  final repo = LoanRepository(service);

  test('v0.3 Logic - Old Loan (2018) should be Paid Off', () {
    final oldLoan = Loan(
      id: 'old',
      name: 'Old Loan',
      type: LoanType.personal,
      currency: Currency.mxn,
      principal: 10000,
      annualRate: 10,
      termMonths: 12, // 1 year term
      startDate: DateTime(2018, 1, 1),
    );

    // Elapsed from 2018 to >2025 is clearly > 12 months
    final elapsed = repo.getMonthsElapsed(oldLoan);
    print('Old Loan Elapsed Months: $elapsed');
    
    expect(elapsed, greaterThan(12), reason: 'Should be many years elapsed');
    expect(repo.getStatus(oldLoan), 'Paid Off', reason: 'Status should be Paid Off');
    expect(repo.getCurrentBalance(oldLoan), 0.0, reason: 'Balance should be 0.0');
    expect(repo.getMonthsRemaining(oldLoan), 0, reason: 'Months remaining should be 0');
  });

  test('v0.3 Logic - New Loan (Today) should be Active', () {
    final now = DateTime.now();
    final newLoan = Loan(
      id: 'new',
      name: 'New Loan',
      type: LoanType.auto,
      currency: Currency.usd,
      principal: 50000,
      annualRate: 5,
      termMonths: 48,
      startDate: now,
    );

    final elapsed = repo.getMonthsElapsed(newLoan);
    print('New Loan Elapsed Months: $elapsed');

    expect(elapsed, 0, reason: 'Should be 0 months elapsed');
    expect(repo.getStatus(newLoan), 'Active', reason: 'Status should be Active');
    expect(repo.getCurrentBalance(newLoan), 50000.0, reason: 'Balance should be Principal');
    expect(repo.getMonthsRemaining(newLoan), 48, reason: 'Months remaining should be full term');
  });
}
