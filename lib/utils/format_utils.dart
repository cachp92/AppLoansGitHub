class FormatUtils {
  static String currency(double value) {
    // Simple formatting: USD 1,234.56 or just 1234.56 based on requirement
    // Requirement said: "USD 200,000.00 (thousands separator optional only if easy; otherwise 200000.00 is OK)"
    // Using simple fix: manual commas or just basic fixed.
    // Let's try a simple regex for commas since no packages allowed.
    String amount = value.toStringAsFixed(2);
    // Add commas
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]},';
    String result = amount.replaceAllMapped(reg, mathFunc);
    return '\$$result';
  }

  static String percentage(double value) {
    return '${value.toStringAsFixed(2)}%';
  }
}
