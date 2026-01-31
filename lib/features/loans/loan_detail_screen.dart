import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../services/amortization_service.dart';
import '../../repositories/loan_repository.dart';
import '../../utils/format_utils.dart';
import '../../models/extra_payment.dart';
import '../../widgets/common_widgets.dart';

class LoanDetailScreen extends StatelessWidget {
  final Loan loan;
  final AmortizationService amortizationService;
  final LoanRepository repository;

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
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(context, '/create-loan', arguments: loan),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                 showDialog(context: context, builder: (ctx) => AlertDialog(
                   title: const Text('Delete Loan?'),
                   content: const Text('Are you sure you want to remove this loan permanently?'),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                     FilledButton(onPressed: () {
                       repository.deleteLoan(loan.id);
                       Navigator.pop(ctx);
                       Navigator.pop(context);
                     }, child: const Text('Delete')),
                   ],
                 ));
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Amortization'),
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
    // Analytics
    final baselineSchedule = amortizationService.calculateAmortization(loan);
    final baselineInterest = baselineSchedule.fold(0.0, (sum, row) => sum + row.interest);
    
    final extrasSchedule = amortizationService.calculateWithExtras(loan);
    final extrasInterest = extrasSchedule.fold(0.0, (sum, row) => sum + row.interest);
    
    final interestSaved = baselineInterest - extrasInterest;
    final monthsSaved = baselineSchedule.length - extrasSchedule.length;

    final progress = repository.getPaidProgress(loan);
    final monthlyPayment = baselineSchedule.isNotEmpty ? baselineSchedule.first.payment : 0.0;
    final status = repository.getStatus(loan);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. High-Level Summary Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current Status', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                    StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monthly Payment', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          const SizedBox(height: 4),
                          MoneyText(amount: monthlyPayment, style: const TextStyle(fontSize: 24)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                           Text('Remaining', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                           const SizedBox(height: 4),
                           MoneyText(
                             amount: loan.principal * (1 - progress),
                             style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor),
                           ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                   value: progress,
                   backgroundColor: Colors.grey.shade100,
                   color: Colors.green,
                   borderRadius: BorderRadius.circular(4),
                   minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text('${(progress * 100).toStringAsFixed(1)}% Paid Off', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 2. Savings Opportunity (if any)
        if (interestSaved > 0 || monthsSaved > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.savings_outlined, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text('Savings Projection', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SavingsItem(label: 'Interest Saved', value: FormatUtils.currency(interestSaved)),
                    Container(width: 1, height: 30, color: Colors.green.shade200),
                    _SavingsItem(label: 'Time Saved', value: '$monthsSaved months'),
                  ],
                )
              ],
            ),
          ),

        if (interestSaved > 0 || monthsSaved > 0) const SizedBox(height: 16),

        // 3. Extra Payments
        _ExtraPaymentsCard(loan: loan, repository: repository, amortizationService: amortizationService),

        const SizedBox(height: 24),
        
        // 4. Detailed Info
        const Text('Loan Particulars', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withOpacity(0.1))
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                InfoRow(label: 'Principal Amount', value: FormatUtils.currency(loan.principal)),
                InfoRow(label: 'Annual Interest Rate', value: FormatUtils.percentage(loan.annualRate)),
                InfoRow(label: 'Loan Term', value: '${loan.termMonths} months'),
                InfoRow(label: 'Start Date', value: FormatUtils.date(loan.startDate)),
                const Divider(),
                InfoRow(label: 'Total Interest (Base)', value: FormatUtils.currency(baselineInterest)),
                InfoRow(label: 'Total Cost (Base)', value: FormatUtils.currency(loan.principal + baselineInterest), isHighlight: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SavingsItem extends StatelessWidget {
  final String label;
  final String value;
  const _SavingsItem({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _ExtraPaymentsCard extends StatelessWidget {
  final Loan loan;
  final LoanRepository repository;
  final AmortizationService amortizationService;

  const _ExtraPaymentsCard({required this.loan, required this.repository, required this.amortizationService});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Extra Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                )
              ],
            ),
            const Divider(),
            if (loan.extraPayments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text('No extra payments yet.', style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic)),
              )
            else
              ...loan.extraPayments.map((ep) => ListTile(
                dense: true,
                title: Text('Month ${ep.period}', style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: Text('+${FormatUtils.currency(ep.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.payments, size: 16, color: Colors.green.shade700),
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
     final periodCtrl = TextEditingController();
     final amountCtrl = TextEditingController();
     
     final schedule = amortizationService.calculateWithExtras(loan);
     
     showDialog(context: context, builder: (ctx) => AlertDialog(
       title: const Text('Add Extra Payment'),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           TextField(
             controller: periodCtrl,
             decoration: const InputDecoration(
               labelText: 'Period (Month #)', 
               hintText: 'e.g., 12',
               border: OutlineInputBorder(),
               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
             ),
             keyboardType: TextInputType.number,
           ),
           const SizedBox(height: 16),
           TextField(
             controller: amountCtrl,
             decoration: const InputDecoration(
               labelText: 'Amount', 
               prefixText: '\$ ',
               border: OutlineInputBorder(),
               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
             ),
             keyboardType: TextInputType.number,
           ),
         ],
       ),
       actions: [
         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
         FilledButton(onPressed: () {
           final p = int.tryParse(periodCtrl.text);
           final a = double.tryParse(amountCtrl.text);

           if (p == null || p <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid period')));
              return;
           }
           if (a == null || a <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount')));
              return;
           }

           double maxAllowed = 0.0;
           if (p == 1) {
             maxAllowed = loan.principal;
           } else if (p - 2 < schedule.length && p - 2 >= 0) {
             maxAllowed = schedule[p - 2].balance;
           } else {
             maxAllowed = 0.0; 
           }

           if (a > maxAllowed) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Amount exceeds balance (${FormatUtils.currency(maxAllowed)}) at month $p'),
                backgroundColor: Colors.red,
              ));
              return;
           }

           final newExtra = ExtraPayment(period: p, amount: a);
           final updatedLoan = loan.copyWith(
             extraPayments: [...loan.extraPayments, newExtra]
           );
           repository.updateLoan(updatedLoan);
           Navigator.pop(ctx);
           
         }, child: const Text('Add Payment')),
       ],
     ));
  }
}

class _AmortizationTab extends StatefulWidget {
  final Loan loan;
  final AmortizationService amortizationService;

  const _AmortizationTab({required this.loan, required this.amortizationService});

  @override
  State<_AmortizationTab> createState() => _AmortizationTabState();
}

class _AmortizationTabState extends State<_AmortizationTab> {
  bool _showBaseline = false;

  @override
  Widget build(BuildContext context) {
    final schedule = _showBaseline 
        ? widget.amortizationService.calculateAmortization(widget.loan)
        : widget.amortizationService.calculateWithExtras(widget.loan);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
            if (widget.loan.extraPayments.isNotEmpty)
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               decoration: BoxDecoration(
                 color: Colors.grey.shade50,
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.grey.shade200),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Text('Mode: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                   Text(_showBaseline ? 'Baseline Schedule' : 'With Extras', style: TextStyle(color: _showBaseline ? Colors.grey : Colors.green, fontWeight: FontWeight.bold)),
                   const SizedBox(width: 8),
                   Switch.adaptive(
                     value: !_showBaseline, 
                     activeColor: Colors.green,
                     onChanged: (v) => setState(() => _showBaseline = !v)
                   ),
                 ],
               ),
             ),
            const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                  columnSpacing: 20,
                  horizontalMargin: 16,
                  columns: const [
                    DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                    DataColumn(label: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                    DataColumn(label: Text('Interest', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                    DataColumn(label: Text('Capital', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                    DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                  ],
                  rows: schedule.map((row) {
                    return DataRow(cells: [
                      DataCell(Text(row.period.toString(), style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold))),
                      DataCell(Text(FormatUtils.currency(row.payment), style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(FormatUtils.currency(row.interest), style: TextStyle(color: Colors.red[300]))),
                      DataCell(Text(FormatUtils.currency(row.capital), style: TextStyle(color: Colors.green[700]))),
                      DataCell(Text(FormatUtils.currency(row.balance), style: TextStyle(color: Colors.grey[600]))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
