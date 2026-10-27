/// Formatos de presentación en español de Colombia.
class Formatters {
  Formatters._();

  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  /// 6887306 -> "6.887.306". Devuelve "Sin dato" si es nulo.
  static String number(int? value) {
    if (value == null) return 'Sin dato';
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// "1887-06-04" -> "4 jun 1887". Si no se puede interpretar, la deja igual.
  static String date(String? value) {
    if (value == null || value.isEmpty) return 'Actualidad';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.day} ${_months[parsed.month - 1]} ${parsed.year}';
  }

  /// Texto o "Sin dato" si viene vacío.
  static String text(String? value) =>
      value == null || value.trim().isEmpty ? 'Sin dato' : value.trim();
}
