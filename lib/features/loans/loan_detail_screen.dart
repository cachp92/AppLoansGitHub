import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../services/amortization_service.dart';
import '../../repositories/loan_repository.dart'; // Added

class LoanDetailScreen extends StatelessWidget {
  final Loan loan;
  final AmortizationService amortizationService;
  final LoanRepository repository; // Added

  const LoanDetailScreen({
    super.key,
    required this.loan,
    required this.amortizationService,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loan.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Amortization Table'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SummaryTab(loan: loan, amortizationService: amortizationService, repository: repository),
            _AmortizationTab(loan: loan, amortizationService: amortizationService),
          ],
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final Loan loan;
  final AmortizationService amortizationService;
  final LoanRepository repository;

  const _SummaryTab({required this.loan, required this.amortizationService, required this.repository});

  @override
  Widget build(BuildContext context) {
    final schedule = amortizationService.calculateAmortization(loan);
    final monthlyPayment = schedule.isNotEmpty ? schedule.first.payment : 0.0;
    final totalInterest = schedule.fold(0.0, (sum, row) => sum + row.interest);
    final progress = repository.getPaidProgress(loan);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text('Status', style: Theme.of(context).textTheme.titleMedium),
                     Chip(
                        label: Text(repository.getStatus(loan), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        backgroundColor: repository.getStatus(loan) == 'Active' ? Colors.green.shade100 : Colors.grey.shade300,
                        side: BorderSide.none,
                     ),
                   ],
                 ),
                 const SizedBox(height: 16),
                 Text('Est. Monthly Payment', style: Theme.of(context).textTheme.titleMedium),
                 const SizedBox(height: 8),
                 Text('\$${monthlyPayment.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                   color: Theme.of(context).colorScheme.primary,
                   fontWeight: FontWeight.bold,
                 )),
                 const SizedBox(height: 24),
                 LinearProgressIndicator(
                   value: progress,
                   backgroundColor: Colors.grey.shade200,
                   minHeight: 8,
                   borderRadius: BorderRadius.circular(4),
                 ),
                 const SizedBox(height: 8),
                 Text('${(progress * 100).toStringAsFixed(1)}% Paid', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _DetailRow(label: 'Principal Amount', value: '\$${loan.principal.toStringAsFixed(2)}'),
        _DetailRow(label: 'Annual Rate', value: '${loan.annualRate}%'),
        _DetailRow(label: 'Term', value: '${loan.termMonths} months'),
        _DetailRow(label: 'Start Date', value: '${loan.startDate.day}/${loan.startDate.month}/${loan.startDate.year}'),
        _DetailRow(label: 'Months Remaining', value: '${repository.getMonthsRemaining(loan)}'),
        _DetailRow(label: 'Total Interest', value: '\$${totalInterest.toStringAsFixed(2)}'),
        _DetailRow(label: 'Total Payable', value: '\$${(loan.principal + totalInterest).toStringAsFixed(2)}'),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AmortizationTab extends StatelessWidget {
  final Loan loan;
  final AmortizationService amortizationService;

  const _AmortizationTab({required this.loan, required this.amortizationService});

  @override
  Widget build(BuildContext context) {
    final schedule = amortizationService.calculateAmortization(loan);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Payment')),
            DataColumn(label: Text('Interest')),
            DataColumn(label: Text('Capital')),
            DataColumn(label: Text('Balance')),
          ],
          rows: schedule.map((row) {
            return DataRow(cells: [
              DataCell(Text(row.period.toString())),
              DataCell(Text(row.payment.toStringAsFixed(2))),
              DataCell(Text(row.interest.toStringAsFixed(2))),
              DataCell(Text(row.capital.toStringAsFixed(2))),
              DataCell(Text(row.balance.toStringAsFixed(2))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
