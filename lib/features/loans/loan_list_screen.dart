import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../dashboard/dashboard_screen.dart'; // For Drawer
import '../../utils/format_utils.dart';

class LoanListScreen extends StatelessWidget {
  final LoanRepository repository;

  const LoanListScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loans'),
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
        onPressed: () {
          Navigator.pushNamed(context, '/create-loan');
        },
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
                   const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text('No loans yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600])),
                   const SizedBox(height: 8),
                   const Text('Add your first loan to get started.', style: TextStyle(color: Colors.grey)),
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
    final isActive = status == 'Active';
    final theme = Theme.of(context);
    
    // Calculate progress
    final totalAmount = loan.principal; // Principal
    final currentBalance = repository.getCurrentBalance(loan);
    // Simple progress estimation: (Total - Balance) / Total. 
    // In real amortization it's complex, but this is a good UI proxy.
    final progress = (totalAmount - currentBalance) / totalAmount;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(context, '/loan-detail', arguments: loan);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Name + Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getIconForType(loan.type), 
                      size: 20, 
                      color: theme.colorScheme.primary
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${loan.type.label} • ${_formatDate(loan.startDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: status, isActive: isActive),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Balance & Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Remaining Balance', style: theme.textTheme.bodySmall),
                  Text(
                    FormatUtils.currency(currentBalance),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: clampedProgress,
                backgroundColor: Colors.grey[200],
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              
              // Footer Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(clampedProgress * 100).toInt()}% Paid', 
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: theme.colorScheme.secondary
                    )
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${repository.getMonthsRemaining(loan)} mos left',
                         style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isActive;

  const _StatusChip({required this.status, required this.isActive});

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
