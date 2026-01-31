import 'dart:math';
import '../models/loan.dart';
import '../models/extra_payment.dart';

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

  List<AmortizationRow> calculateWithExtras(Loan loan) {
    if (loan.extraPayments.isEmpty) return calculateAmortization(loan);

    List<AmortizationRow> table = [];
    double remainingBalance = loan.principal;
    double monthlyRate = loan.annualRate / 100 / 12;
    int n = loan.termMonths;

    // Fixed Monthly Payment (Baseline)
    double monthlyPayment;
    if (monthlyRate == 0) {
      monthlyPayment = loan.principal / n;
    } else {
      monthlyPayment = (loan.principal * monthlyRate) / (1 - pow(1 + monthlyRate, -n));
    }
    monthlyPayment = _round(monthlyPayment);

    for (int i = 1; i <= n; i++) {
        if (remainingBalance <= 0.01) break;

        double interest = _round(remainingBalance * monthlyRate);
        double extra = 0;
        
        // Find extra payment for this period
        for (var ep in loan.extraPayments) {
           if (ep.period == i) extra += ep.amount;
        }

        // Cap extra if it exceeds remaining
        // Actually, we usually pay Payment + Extra. 
        // If Payment + Extra > Balance + Interest, we cap payment.
        
        double totalPayload = monthlyPayment + extra;
        double maxNeeded = remainingBalance + interest;
        
        double actualPayment = monthlyPayment;
        double actualExtra = extra;

        if (totalPayload > maxNeeded) {
           // We are paying off.
           // Priority: Pay Interest first, then Principal.
           if (maxNeeded <= interest) {
              // Should not happen unless balance is tiny
              actualPayment = maxNeeded;
              actualExtra = 0;
           } else {
              // Pay full interest
              // Remaining amount covers principal
              // Logic: Adjust visual payment to cover exactly what's needed
               actualPayment = maxNeeded - extra; // This might be weird if extra is huge.
               // Let's simpler:
               // Capital = TotalPayload - Interest. 
               // If Capital > RemainingBalance, Capital = RemainingBalance.
               // TotalPayload = Capital + Interest.
           }
           double theoreticalCapital = totalPayload - interest;
           if (theoreticalCapital > remainingBalance) {
               double excess = theoreticalCapital - remainingBalance;
               // Reduce from totalPayload
               totalPayload -= excess;
           }
        }
        
        // Recalculate components based on capped TotalPayload
        double capital = _round(totalPayload - interest);
        // Safety check
        if (capital > remainingBalance) capital = remainingBalance;
        
        remainingBalance = _round(remainingBalance - capital);
        
        table.add(AmortizationRow(
          period: i,
          payment: _round(capital + interest),
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
