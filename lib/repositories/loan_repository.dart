import 'package:flutter/foundation.dart';
import '../models/loan.dart';
import '../services/amortization_service.dart';

class LoanRepository extends ChangeNotifier {
  final List<Loan> _loans = [];
  final AmortizationService _amortizationService;

  LoanRepository(this._amortizationService) {
    _seedDemoData();
  }

  List<Loan> get loans => List.unmodifiable(_loans);

  void _seedDemoData() {
    if (_loans.isNotEmpty) return;
    
    final now = DateTime.now();
    _loans.addAll([
      Loan(name: 'Personal Loan', type: LoanType.personal, currency: Currency.mxn, principal: 50000, annualRate: 15, termMonths: 24, startDate: now.subtract(const Duration(days: 90))),
      Loan(name: 'Mortgage', type: LoanType.hipotecario, currency: Currency.usd, principal: 250000, annualRate: 4.5, termMonths: 240, startDate: DateTime(2020, 1, 15)),
      Loan(name: 'Hybrid Car', type: LoanType.auto, currency: Currency.mxn, principal: 350000, annualRate: 11.9, termMonths: 48, startDate: now),
      Loan(name: 'Visa Credit', type: LoanType.creditCard, currency: Currency.usd, principal: 2000, annualRate: 18, termMonths: 12, startDate: now.subtract(const Duration(days: 30))),
    ]);
  }

  void resetData() {
    _loans.clear();
    _seedDemoData();
    notifyListeners();
  }

  void addLoan(Loan loan) {
    _loans.add(loan);
    notifyListeners();
  }
  
  void updateLoan(Loan updatedLoan) {
    final index = _loans.indexWhere((l) => l.id == updatedLoan.id);
    if (index != -1) {
      _loans[index] = updatedLoan;
      notifyListeners();
    }
  }

  void deleteLoan(String id) {
    _loans.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // Dashboard Totals
  int get totalLoansCount => _loans.length;

  double get totalBalance {
    double sum = 0;
    for (var loan in _loans) {
      // Current balance is technically Amortization based on current date vs start date.
      // MVP simplification: Show initial principal sum OR "Current Outstanding Balance".
      // Let's do Outstanding Balance based on Amortization if possible, 
      // but "Simplicity" + "No Date Logic Complexity" suggests maybe just Principal for now?
      // User request: "Saldo total (suma de saldos actuales)". 
      // Since time doesn't pass in a real-time simulation easily without current date logic,
      // let's assume "Start Date" implies we might be at period 0 or we calculate strict balance.
      // For MVP V0.1: Let's simpler sum the initial principals for now OR 
      // calculate balance if start date is in past.
      
      // Better approach for strict MVP manual test: Calculate amortization table and take the balance 
      // corresponding to "now". If now < start, balance = principal.
      
      sum += _calculateCurrentBalance(loan);
    }
    return sum;
  }

  double get totalMonthlyPayment {
    double sum = 0;
    for (var loan in _loans) {
      var table = _amortizationService.calculateAmortization(loan);
      if (table.isNotEmpty) {
        sum += table.first.payment; // Fixed payment (approx)
      }
    }
    return sum;
  }

  double _calculateCurrentBalance(Loan loan) {
    if (loan.principal <= 0) return 0.0;
    
    // Calculate months elapsed since start date
    final elapsed = getMonthsElapsed(loan);
    
    // If loan is new (0 months or negative), balance is principal
    if (elapsed <= 0) return loan.principal;

    // Use calculateWithExtras to account for any extras (though demo data has none initially)
    // Using calculateWithExtras covers both base and extra scenarios.
    final schedule = _amortizationService.calculateWithExtras(loan);
    
    if (schedule.isEmpty) return loan.principal;

    // If elapsed > term or schedule, returning 0 is handled in getStatus logic 
    // or we can safely return 0 here if index exceeds table.
    if (elapsed >= schedule.length) {
      return schedule.last.balance; // Should be 0 or close to 0
    }

    // Schedule is 1-based period (row 0 is period 1).
    // If elapsed is 1 month, we want balance after payment 1 (index 0).
    return schedule[elapsed - 1].balance;
  }

  // Helpers
  int getMonthsElapsed(Loan loan) {
    final now = DateTime.now();
    return (now.year - loan.startDate.year) * 12 + now.month - loan.startDate.month;
  }

  int getMonthsRemaining(Loan loan) {
    final elapsed = getMonthsElapsed(loan);
    return (loan.termMonths - elapsed) < 0 ? 0 : (loan.termMonths - elapsed);
  }

  double getMonthlyPayment(Loan loan) {
    final schedule = _amortizationService.calculateAmortization(loan);
    return schedule.isNotEmpty ? schedule.first.payment : 0.0;
  }

  double getCurrentBalance(Loan loan) {
     final elapsed = getMonthsElapsed(loan);
     if (elapsed >= loan.termMonths) return 0.0;
     return _calculateCurrentBalance(loan);
  }

  String getStatus(Loan loan) {
    final elapsed = getMonthsElapsed(loan);
    final balance = getCurrentBalance(loan); // Will be 0 if elapsed >= term
    // Status Logic: Paid Off if time up OR balance 0
    if (elapsed >= loan.termMonths || balance <= 0.01) {
      return 'Paid Off';
    }
    return 'Active';
  }

  double getPaidProgress(Loan loan) {
    if (loan.principal == 0) return 1.0;
    final balance = getCurrentBalance(loan);
    return (loan.principal - balance) / loan.principal;
  }
}
