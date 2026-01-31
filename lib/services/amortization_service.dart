import 'dart:math';
import '../models/loan.dart';

class AmortizationRow {
  final int period;
  final double payment;
  final double interest;
  final double capital;
  final double balance;

  AmortizationRow({
    required this.period,
    required this.payment,
    required this.interest,
    required this.capital,
    required this.balance,
  });
}

class AmortizationService {
  List<AmortizationRow> calculateAmortization(Loan loan) {
    if (loan.principal <= 0 || loan.termMonths <= 0) return [];

    List<AmortizationRow> table = [];
    double remainingBalance = loan.principal;
    double monthlyRate = loan.annualRate / 100 / 12;
    int n = loan.termMonths;

    // PMT Formula: P * r / (1 - (1+r)^-n)
    double monthlyPayment;
    if (monthlyRate == 0) {
      monthlyPayment = loan.principal / n;
    } else {
      monthlyPayment = (loan.principal * monthlyRate) / (1 - pow(1 + monthlyRate, -n));
    }

    // Round payment to 2 decimals usually, but for calculation we keep precision until display? 
    // Requirement says: "Round to 2 decimals each row". 
    // Usually fixed payment is set. Let's fix it to 2 decimals.
    monthlyPayment = _round(monthlyPayment);

    for (int i = 1; i <= n; i++) {
      double interest = _round(remainingBalance * monthlyRate);
      double capital;
      
      // If payment is less than interest (rare but possible with bad input), we have negative amortization. 
      // Assuming standard loans.
      
      if (i == n) {
        // Last row adjustment
        capital = remainingBalance;
        monthlyPayment = capital + interest; // Adjust payment for last month
        remainingBalance = 0.00;
      } else {
         capital = _round(monthlyPayment - interest);
         remainingBalance = _round(remainingBalance - capital);
      }

      table.add(AmortizationRow(
        period: i,
        payment: monthlyPayment,
        interest: interest,
        capital: capital,
        balance: remainingBalance,
      ));
    }
    
    return table;
  }

  double _round(double val) {
    return (val * 100).roundToDouble() / 100;
  }
}
