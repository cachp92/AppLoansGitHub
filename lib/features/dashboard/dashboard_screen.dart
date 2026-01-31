import 'package:flutter/material.dart';
import '../../repositories/loan_repository.dart';
import '../../utils/format_utils.dart';

class DashboardScreen extends StatelessWidget {
  final LoanRepository repository;

  const DashboardScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Overview'),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
        ],
      ),
      drawer: AppDrawer(repository: repository),
      body: ListenableBuilder(
        listenable: repository,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCard(
                  title: 'Total Principals',
                  value: FormatUtils.currency(repository.totalBalance),
                  subtitle: 'Remaining Debt',
                  icon: Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                  isHero: true,
                ),
                const SizedBox(height: 24),
                Text('Quick Stats',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Active Loans',
                        value: '${repository.totalLoansCount}',
                        subtitle: 'Loans',
                        icon: Icons.assignment_outlined,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Monthly Bill',
                        value: FormatUtils.currency(repository.totalMonthlyPayment),
                        subtitle: 'Obligations',
                        icon: Icons.calendar_today_outlined,
                        color: Colors.orange,
                      ),
                    ),
                  ],
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
  final bool isHero;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = isHero ? theme.colorScheme.primary : Colors.white;
    final textColor = isHero ? Colors.white : theme.colorScheme.onSurface;
    final subTextColor = isHero ? Colors.white70 : Colors.grey[500];
    final iconBg = isHero ? Colors.white24 : color.withOpacity(0.1);
    final iconColor = isHero ? Colors.white : color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isHero ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: isHero
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (isHero) const Icon(Icons.more_horiz, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 20),
          Text(subtitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: subTextColor,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              )),
        ],
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
