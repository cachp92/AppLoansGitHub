import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../services/amortization_service.dart';
import '../../repositories/loan_repository.dart';
import '../../utils/format_utils.dart';
import '../../models/extra_payment.dart';

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
              onPressed: () {
                Navigator.pushNamed(context, '/create-loan', arguments: loan);
              },
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
                       Navigator.pop(ctx); // Dialog
                       Navigator.pop(context); // Screen
                     }, child: const Text('Delete')),
                   ],
                 ));
              },
            ),
          ],
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
    // Baseline calculations
    final baselineSchedule = amortizationService.calculateAmortization(loan);
    final baselineInterest = baselineSchedule.fold(0.0, (sum, row) => sum + row.interest);
    
    // With Extras calculations
    final extrasSchedule = amortizationService.calculateWithExtras(loan);
    final extrasInterest = extrasSchedule.fold(0.0, (sum, row) => sum + row.interest);
    final totalPaid = extrasSchedule.fold(0.0, (sum, row) => sum + row.payment); // approximate total paid including extras
    
    final interestSaved = baselineInterest - extrasInterest;
    final monthsSaved = baselineSchedule.length - extrasSchedule.length;

    final progress = repository.getPaidProgress(loan);
    final monthlyPayment = baselineSchedule.isNotEmpty ? baselineSchedule.first.payment : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ... (Status Card - kept same/similar)
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text('Current Status', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
                     Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: repository.getStatus(loan) == 'Active' ? Colors.green.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: repository.getStatus(loan) == 'Active' ? Colors.green.shade200 : Colors.grey.shade300),
                        ),
                        child: Text(
                          repository.getStatus(loan),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: repository.getStatus(loan) == 'Active' ? Colors.green.shade700 : Colors.grey.shade700
                          )
                        ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 24),
                 Text('Est. Monthly Payment', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                 const SizedBox(height: 4),
                 Text(FormatUtils.currency(monthlyPayment), style: Theme.of(context).textTheme.displaySmall?.copyWith(
                   color: Theme.of(context).colorScheme.primary,
                   fontWeight: FontWeight.bold,
                   fontSize: 32,
                 )),
                 const SizedBox(height: 24),
                 ClipRRect(
                   borderRadius: BorderRadius.circular(4),
                   child: LinearProgressIndicator(
                     value: progress,
                     backgroundColor: Colors.grey.shade100,
                     color: Colors.green,
                     minHeight: 8,
                   ),
                 ),
                 const SizedBox(height: 8),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text('${(progress * 100).toStringAsFixed(1)}% Paid', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                     Text('Remaining: ${FormatUtils.currency(loan.principal * (1 - progress))}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                   ],
                 )
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Savings Card (New)
        if (interestSaved > 0 || monthsSaved > 0)
          Card(
            elevation: 0,
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.green.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Savings Summary', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Interest Saved', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                          Text(FormatUtils.currency(interestSaved), style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Time Saved', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                          Text('$monthsSaved months', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),
        
        // Extra Payments Section (New)
        _ExtraPaymentsCard(loan: loan, repository: repository, amortizationService: amortizationService),

        const SizedBox(height: 24),
        Text('Loan Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _DetailRow(label: 'Principal Amount', value: FormatUtils.currency(loan.principal)),
        _DetailRow(label: 'Annual Interest Rate', value: FormatUtils.percentage(loan.annualRate)),
        _DetailRow(label: 'Loan Term', value: '${loan.termMonths} months'),
        _DetailRow(label: 'Start Date', value: '${loan.startDate.day}/${loan.startDate.month}/${loan.startDate.year}'),
        _DetailRow(label: 'Months Remaining', value: '${repository.getMonthsRemaining(loan)}'),
        const Divider(height: 32),
        _DetailRow(label: 'Total Interest (Base)', value: FormatUtils.currency(baselineInterest)),
        _DetailRow(label: 'Total Payable (Base)', value: FormatUtils.currency(loan.principal + baselineInterest)),
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
            if (loan.extraPayments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No extra payments yet.', style: TextStyle(color: Colors.grey[500])),
              )
            else
              ...loan.extraPayments.map((ep) => ListTile(
                dense: true,
                title: Text('Month ${ep.period}'),
                trailing: Text('+${FormatUtils.currency(ep.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments, size: 18, color: Colors.grey),
              )).toList(),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
     final periodCtrl = TextEditingController();
     final amountCtrl = TextEditingController();
     
     // Calculate current constraints based on existing extras
     final schedule = amortizationService.calculateWithExtras(loan);
     
     showDialog(context: context, builder: (ctx) => AlertDialog(
       title: const Text('Add Extra Payment'),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           TextField(
             controller: periodCtrl,
             decoration: const InputDecoration(labelText: 'Month Period (e.g. 1, 12)', hintText: 'Enter month number'),
             keyboardType: TextInputType.number,
           ),
           const SizedBox(height: 12),
           TextField(
             controller: amountCtrl,
             decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
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

           // Check max allowed
           // Balance at previous month (p-1)
           // If p=1, max is principal. 
           // If p > 1, max is schedule[p-2].balance
           double maxAllowed = 0.0;
           if (p == 1) {
             maxAllowed = loan.principal;
           } else if (p - 2 < schedule.length && p - 2 >= 0) {
             maxAllowed = schedule[p - 2].balance;
           } else {
             // Loan might be already paid off by this point
             maxAllowed = 0.0; 
           }

           if (a > maxAllowed) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Amount exceeds balance ($maxAllowed) at month $p'),
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
           
         }, child: const Text('Add')),
       ],
     ));
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _DetailRow({required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: Colors.grey[700],
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal
          )),
          Text(value, style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isHighlight ? Colors.black : Colors.grey[900]
          )),
        ],
      ),
    );
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
           // Toggle Switch
           if (widget.loan.extraPayments.isNotEmpty)
             Padding(
               padding: const EdgeInsets.only(bottom: 8.0),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   const Text('Show Baseline'),
                   Switch(
                     value: _showBaseline, 
                     onChanged: (v) => setState(() => _showBaseline = v)
                   ),
                 ],
               ),
             ),
             
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
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Interest', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Capital', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: schedule.map((row) {
                    return DataRow(cells: [
                      DataCell(Text(row.period.toString(), style: TextStyle(color: Colors.grey[600]))),
                      DataCell(Text(FormatUtils.currency(row.payment), style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(FormatUtils.currency(row.interest))),
                      DataCell(Text(FormatUtils.currency(row.capital))),
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
