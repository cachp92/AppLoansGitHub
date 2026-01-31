import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/amortization_service.dart';
import 'repositories/loan_repository.dart';
import 'models/loan.dart';

// Features
import 'features/dashboard/dashboard_screen.dart';
import 'features/loans/loan_list_screen.dart';
import 'features/loans/loan_form_screen.dart';
import 'features/loans/loan_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Dependencies (Manual Injection)
  final amortizationService = AmortizationService();
  final loanRepository = LoanRepository(amortizationService);

  runApp(AppLoans(
    loanRepository: loanRepository,
    amortizationService: amortizationService,
  ));
}

class AppLoans extends StatelessWidget {
  final LoanRepository loanRepository;
  final AmortizationService amortizationService;

  const AppLoans({
    super.key,
    required this.loanRepository,
    required this.amortizationService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Loans',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Honors system preference
      initialRoute: '/',
      routes: {
        '/': (context) => DashboardScreen(repository: loanRepository),
        '/loans': (context) => LoanListScreen(repository: loanRepository),
        '/create-loan': (context) => LoanFormScreen(repository: loanRepository),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/loan-detail') {
          final loan = settings.arguments as Loan;
          return MaterialPageRoute(
            builder: (context) => LoanDetailScreen(
              loan: loan,
              amortizationService: amortizationService,
              repository: loanRepository, // Added
            ),
          );
        }
        return null;
      },
    );
  }
}
