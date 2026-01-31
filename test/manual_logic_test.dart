import 'package:flutter_test/flutter_test.dart';
import 'package:app_loans_ag/models/loan.dart';
import 'package:app_loans_ag/services/amortization_service.dart';
import 'package:app_loans_ag/repositories/loan_repository.dart';

void main() {
  test('Verify "Auto Test" Amortization Logic', () {
    final service = AmortizationService();
    
    // "Auto Test" (MXN 200000, 12%, 24 months)
    final loan = Loan(
      id: 'test',
      name: 'Auto Test',
      type: LoanType.auto,
      currency: Currency.mxn,
      principal: 200000,
      annualRate: 12,
      termMonths: 24,
      startDate: DateTime.now(),
    );

    final schedule = service.calculateAmortization(loan);
    expect(schedule.length, 24, reason: 'Should have 24 periods');

    // 2. Verify monthly payment (approx)
    final payment = schedule.first.payment;
    print('Monthly Payment: \$${payment}');
    expect(payment, closeTo(9414.69, 0.1), reason: 'Payment should be around 9414.69');

    // 3. Verify last balance is exactly 0.00
    final lastRow = schedule.last;
    print('Last Row Balance: ${lastRow.balance}');
    expect(lastRow.balance, 0.00, reason: 'Last balance must be exactly 0.00');
    
    // 4. Verify Repository Helpers (Status/Progress)
    // Need to mock repository or just test logic if we extract it, 
    // but here we can just test the logic inline or instantiate repo.
    // Let's instantiate Repo.
    final repo = LoanRepository(service);
    repo.addLoan(loan);
    
    expect(repo.getStatus(loan), 'Active', reason: 'Status should be Active');
    expect(repo.getPaidProgress(loan), 0.0, reason: 'Progress should be 0.0 initially');
    expect(repo.getCurrentBalance(loan), 200000.0, reason: 'Balance should be principal');
  });
}
