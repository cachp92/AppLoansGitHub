class FormatUtils {
  static String currency(double value) {
    if (value == 0) return '\$0.00';
    // Manual 2 decimal places
    final String basic = value.toStringAsFixed(2);
    // Add commas manually if desired, or keep simple as per requirement "Thousands separators optional"
    // Let's do simple regex for thousands to look "Premium"
    // Split integer and decimal
    final parts = basic.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );
    return '\$$integerPart.${parts[1]}';
  }

  static String percentage(double value) {
    return '${value.toStringAsFixed(2)}%';
  }

  static String date(DateTime date) {
    // YYYY-MM-DD
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
