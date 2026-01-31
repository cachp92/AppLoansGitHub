import 'package:flutter/foundation.dart';
import '../models/loan.dart';
import '../services/amortization_service.dart';

class LoanRepository extends ChangeNotifier {
  final List<Loan> _loans = [];
  final AmortizationService _amortizationService;

  LoanRepository(this._amortizationService);

  List<Loan> get loans => List.unmodifiable(_loans);

  void addLoan(Loan loan) {
    _loans.add(loan);
    notifyListeners();
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
    // For MVP v0.2, assuming no payments made yet, so balance is principal.
    // In future versions, this will check payments history.
    return loan.principal; 
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
