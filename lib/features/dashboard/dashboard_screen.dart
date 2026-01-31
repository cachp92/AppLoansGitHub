import 'package:flutter/material.dart';
import '../../repositories/loan_repository.dart';

class DashboardScreen extends StatelessWidget {
  final LoanRepository repository;

  const DashboardScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: AppDrawer(repository: repository),
      body: ListenableBuilder(
        listenable: repository,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SummaryCard(
                  title: 'Total Loans',
                  value: '${repository.totalLoansCount}',
                  icon: Icons.filter_none,
                  color: Colors.blueAccent,
                ),
                _SummaryCard(
                  title: 'Total Balance',
                  value: '\$${repository.totalBalance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                _SummaryCard(
                  title: 'Total Monthly Payment',
                  value: '\$${repository.totalMonthlyPayment.toStringAsFixed(2)}',
                  icon: Icons.calendar_today,
                  color: Colors.orange,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Simple Shared Drawer
class AppDrawer extends StatelessWidget {
  final LoanRepository repository;

  const AppDrawer({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.monetization_on, color: Colors.white, size: 48),
                SizedBox(height: 10),
                Text('App Loans', style: TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('My Loans'),
            onTap: () => Navigator.pushReplacementNamed(context, '/loans'),
          ),
        ],
      ),
    );
  }
}
