import 'package:flutter/material.dart';
import '../../repositories/loan_repository.dart';
import '../../utils/format_utils.dart';

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
                  title: 'Active Loans',
                  value: '${repository.totalLoansCount}',
                  subtitle: 'Total registered',
                  icon: Icons.assignment,
                  color: Colors.blueAccent,
                ),
                _SummaryCard(
                  title: 'Total Principal',
                  value: FormatUtils.currency(repository.totalBalance),
                  subtitle: 'Remaining balance',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                _SummaryCard(
                  title: 'Monthly Commitments',
                  value: FormatUtils.currency(repository.totalMonthlyPayment),
                  subtitle: 'Total estimated payments',
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
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      )),
                  const SizedBox(height: 4),
                  Text(value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      )),
                ],
              ),
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
