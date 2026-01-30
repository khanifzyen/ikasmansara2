import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Only allow digits
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Prevent leading zeros
    if (newText.startsWith('0') && newText.length > 1) {
      newText = newText.substring(1);
    }

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final double value = double.tryParse(newText) ?? 0;
    final String formatted = _formatter.format(value).trim();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
