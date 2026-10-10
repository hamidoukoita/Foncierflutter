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
}
