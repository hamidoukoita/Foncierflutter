import 'package:intl/intl.dart';

/// Formatage des montants en Franc CFA.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _entier = NumberFormat('#,##0', 'en_US');

  /// 14500000 → "14 500 000 FCFA"
  static String fcfa(double montant) =>
      '${_entier.format(montant).replaceAll(',', ' ')} FCFA';

  /// 14500000 → "14,5 M FCFA" ; 850000 → "850 000 FCFA"
  static String fcfaCompact(double montant) {
    if (montant < 1000000) return fcfa(montant);
    final millions = montant / 1000000;
    final texte = millions == millions.roundToDouble()
        ? millions.toStringAsFixed(0)
        : millions.toStringAsFixed(1).replaceAll('.', ',');
    return '$texte M FCFA';
  }
}
