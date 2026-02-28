import 'package:flutter/services.dart';

String formatPhoneNumber(String input) {
  final digits = digitsOnlyPhone(input);

  if (digits.length == 11 && digits.startsWith('1')) {
    final localDigits = digits.substring(1);
    return '+1 ${formatPhoneNumber(localDigits)}';
  }

  if (digits.length >= 10) {
    final area = digits.substring(0, 3);
    final prefix = digits.substring(3, 6);
    final line = digits.substring(6, 10);
    return '($area) $prefix-$line';
  }

  if (digits.length >= 7) {
    final prefix = digits.substring(0, 3);
    final line = digits.substring(3);
    return '$prefix-$line';
  }

  return digits;
}

String digitsOnlyPhone(String input) {
  return input.replaceAll(RegExp(r'\D'), '');
}

class UsPhoneTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = digitsOnlyPhone(newValue.text);
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i += 1) {
      if (i == 0) {
        buffer.write('(');
      } else if (i == 3) {
        buffer.write(') ');
      } else if (i == 6) {
        buffer.write('-');
      }
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
