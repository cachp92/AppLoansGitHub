import 'package:flutter/material.dart';
import '../utils/format_utils.dart';

class MoneyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final Color? color;

  const MoneyText({
    super.key, 
    required this.amount, 
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = style ?? theme.textTheme.titleMedium;
    return Text(
      FormatUtils.currency(amount),
      style: baseStyle?.copyWith(
        color: color ?? baseStyle.color,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const InfoRow({
    super.key, 
    required this.label, 
    required this.value, 
    this.isHighlight = false
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          )),
          Text(value, style: TextStyle(
            color: isHighlight ? Colors.black87 : Colors.grey[800],
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
          )),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status; // "Active" or "Paid Off"

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.grey.shade300
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
