import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../dashboard/dashboard_screen.dart'; // For Drawer

class LoanListScreen extends StatelessWidget {
  final LoanRepository repository;

  const LoanListScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Loans')),
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
            return const Center(
              child: Text('No loans registered.', style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: repository.loans.length,
            itemBuilder: (context, index) {
              final loan = repository.loans[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(_getIconForType(loan.type), color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(loan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${loan.type.label} • ${loan.currency.label}'),
                        trailing: Chip(
                          label: Text(repository.getStatus(loan), style: const TextStyle(fontSize: 12)),
                          backgroundColor: repository.getStatus(loan) == 'Active' ? Colors.green.shade100 : Colors.grey.shade300,
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/loan-detail', arguments: loan);
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Monthly Payment', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              Text('\$${repository.getMonthlyPayment(loan).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Current Balance', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              Text('\$${repository.getCurrentBalance(loan).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // New Row for Date and Time Remaining
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Start: ${_formatDate(loan.startDate)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          Text('${repository.getMonthsRemaining(loan)} mos left', style: TextStyle(color: Colors.orange[800], fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
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
