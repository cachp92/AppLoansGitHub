import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../dashboard/dashboard_screen.dart'; // For Drawer
import '../../utils/format_utils.dart';
import '../../widgets/common_widgets.dart';

class LoanListScreen extends StatelessWidget {
  final LoanRepository repository;

  const LoanListScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loans'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Demo Data',
            onPressed: () {
               // Confirm
               showDialog(context: context, builder: (ctx) => AlertDialog(
                 title: const Text('Reset Demo Data?'),
                 content: const Text('This will delete all current loans and restore 4 demo loans.'),
                 actions: [
                   TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                   FilledButton(onPressed: () {
                     repository.resetData();
                     Navigator.pop(ctx);
                   }, child: const Text('Reset')),
                 ],
               ));
            },
          )
        ],
      ),
      drawer: AppDrawer(repository: repository),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-loan'),
        label: const Text('New Loan'),
        icon: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: repository,
        builder: (context, _) {
          if (repository.loans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       color: Colors.grey.shade100,
                       shape: BoxShape.circle,
                     ),
                     child: Icon(Icons.folder_open, size: 48, color: Colors.grey.shade400),
                   ),
                   const SizedBox(height: 24),
                   Text('No loans yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[800])),
                   const SizedBox(height: 8),
                   Text('Add your first loan to get started.', style: TextStyle(color: Colors.grey[600])),
                   const SizedBox(height: 24),
                   FilledButton.tonalIcon(
                     onPressed: () => Navigator.pushNamed(context, '/create-loan'),
                     icon: const Icon(Icons.add),
                     label: const Text('Add your first loan'),
                   ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: repository.loans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final loan = repository.loans[index];
              return _LoanCard(loan: loan, repository: repository);
            },
          );
        },
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;
  final LoanRepository repository;

  const _LoanCard({required this.loan, required this.repository});

  @override
  Widget build(BuildContext context) {
    final status = repository.getStatus(loan);
    final isActive = status == 'Active'; // Keep for MoneyText styling

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/loan-detail', arguments: loan),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Name + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      loan.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusChip(status: status, isActive: isActive),
                ],
              ),
              const SizedBox(height: 8),

              // Type + Date
              Row(
                children: [
                  Icon(_getIconForType(loan.type), size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${loan.type.label} • ${FormatUtils.date(loan.startDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),

              // Bottom Row: Payment + Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Monthly', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                       MoneyText(amount: repository.getMonthlyPayment(loan)),
                     ],
                   ),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Text('Balance', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                       MoneyText(
                         amount: repository.getCurrentBalance(loan),
                         style: TextStyle(
                           color: isActive ? Theme.of(context).primaryColor : Colors.grey[700],
                           fontSize: 18,
                         )
                       ),
                     ],
                   ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${repository.getMonthsRemaining(loan)} months left',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(LoanType type) {
    switch (type) {
      case LoanType.personal: return Icons.person;
      case LoanType.hipotecario: return Icons.home;
      case LoanType.auto: return Icons.directions_car;
      case LoanType.creditCard: return Icons.credit_card;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isActive;
  const _StatusChip({super.key, required this.status, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
