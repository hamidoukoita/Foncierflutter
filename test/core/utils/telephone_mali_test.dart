import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/telephone_mali.dart';

void main() {
  test('accepte les numéros maliens à 8 chiffres', () {
    expect(TelephoneMali.valider('76 12 34 56'), isNull);
    expect(TelephoneMali.valider('70000000'), isNull);
    expect(TelephoneMali.valider('20 22 33 44'), isNull);
  });

  test('refuse les longueurs et préfixes invalides', () {
    expect(TelephoneMali.valider(''), 'Numéro obligatoire');
    expect(TelephoneMali.valider('7612345'), isNotNull);
    expect(TelephoneMali.valider('16 12 34 56'), 'Numéro malien invalide');
    expect(TelephoneMali.valider('46 12 34 56'), 'Numéro malien invalide');
  });

  test('met en forme pendant la saisie et limite à 8 chiffres', () {
    final f = TelephoneMaliFormatter();
    final v = f.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '7612345699'));
    expect(v.text, '76 12 34 56');
    expect(TelephoneMali.chiffres(v.text), '76123456');
  });
}
