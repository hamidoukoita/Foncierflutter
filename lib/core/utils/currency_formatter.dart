import 'package:intl/intl.dart';

/// Formatage des montants en FCFA (séparateur de milliers français).
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _fmt = NumberFormat.decimalPattern('fr_FR');

  /// 5000000 -> "5 000 000 FCFA" ; null -> "—"
  static String fcfa(num? value) {
    if (value == null) return '—';
    return '${_fmt.format(value.round())} FCFA';
  }

  /// 14500000 -> "14,5 M FCFA" ; 850000 -> "850 000 FCFA" ; null -> "—"
  static String fcfaCompact(num? value) {
    if (value == null || value < 1000000) return fcfa(value);
    final millions = value / 1000000;
    final texte = millions == millions.roundToDouble()
        ? millions.toStringAsFixed(0)
        : millions.toStringAsFixed(1).replaceAll('.', ',');
    return '$texte M FCFA';
  }
}
