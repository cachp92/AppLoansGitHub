
import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';

class LoanFormScreen extends StatefulWidget {
  final LoanRepository repository;
  final Loan? loan; // Optional for edit

  const LoanFormScreen({super.key, required this.repository, this.loan});

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _rateController;
  late TextEditingController _termController;
  
  // State
  late LoanType _selectedType;
  late Currency _selectedCurrency;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    final l = widget.loan;
    _nameController = TextEditingController(text: l?.name ?? '');
    _amountController = TextEditingController(text: l?.principal.toString() ?? '');
    _rateController = TextEditingController(text: l?.annualRate.toString() ?? '');
    _termController = TextEditingController(text: l?.termMonths.toString() ?? '');
    
    _selectedType = l?.type ?? LoanType.personal;
    _selectedCurrency = l?.currency ?? Currency.mxn;
    _startDate = l?.startDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.loan == null ? 'New Loan' : 'Edit Loan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ... existing widgets will use the controllers initialized in initState
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Loan Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<LoanType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Loan Type'),
                items: LoanType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.label),
                )).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
                decoration: const InputDecoration(labelText: 'Currency'),
                items: Currency.values.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.label),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCurrency = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Principal Amount', prefixText: '\$'),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      decoration: const InputDecoration(labelText: 'Annual Rate (%)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _termController,
                      decoration: const InputDecoration(labelText: 'Term (Months)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start Date'),
                        child: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saveLoan,
                  child: Text(widget.loan == null ? 'Save Loan' : 'Update Loan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveLoan() async {
    if (_formKey.currentState!.validate()) {
      final loan = Loan(
        id: widget.loan?.id, // Keep ID if editing
        name: _nameController.text,
        type: _selectedType,
        currency: _selectedCurrency,
        principal: double.parse(_amountController.text),
        annualRate: double.parse(_rateController.text),
        termMonths: int.parse(_termController.text),
        startDate: _startDate,
        extraPayments: widget.loan?.extraPayments ?? [], // Preserve extras
      );

      try {
        if (widget.loan == null) {
          await widget.repository.addLoan(loan);
        } else {
          await widget.repository.updateLoan(loan);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving loan: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
