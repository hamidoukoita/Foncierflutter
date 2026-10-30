import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/pays.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/telephone.dart';

void main() {
  final france = Pays.parIso('FR')!;

  test('accepte les numéros maliens à 8 chiffres', () {
    expect(Telephone.valider(Pays.mali, '76 12 34 56'), isNull);
    expect(Telephone.valider(Pays.mali, '70000000'), isNull);
    expect(Telephone.valider(Pays.mali, '20 22 33 44'), isNull);
  });

  test('refuse un numéro vide ou invalide pour son pays, avec un exemple', () {
    expect(Telephone.valider(Pays.mali, ''), 'Numéro obligatoire');
    expect(Telephone.valider(Pays.mali, '7612345'), isNotNull);
    expect(Telephone.valider(france, '6 12'), 'Numéro invalide pour France (ex. 6 12 34 56 78)');
  });

  test('envoie le numéro au format international E.164', () {
    expect(Telephone.e164(Pays.mali, '76 12 34 56'), '+22376123456');
    expect(Telephone.e164(france, '6 12 34 56 78'), '+33612345678');
    expect(Telephone.e164(france, '06 12 34 56 78'), '+33612345678');
  });

  test('affiche les numéros enregistrés, anciens comme nouveaux', () {
    expect(Telephone.afficher('+22376123456'), '76 12 34 56');
    expect(Telephone.afficher('+22376123456', avecIndicatif: true), '+223 76 12 34 56');
    expect(Telephone.afficher('76123456'), '76 12 34 56');
    expect(Telephone.afficher('+33612345678'), '+33 6 12 34 56 78');
    expect(Telephone.paysDe('+33612345678').iso, 'FR');
    expect(Telephone.nationalDe('+33612345678'), '6 12 34 56 78');
  });

  test('met en forme selon le pays pendant la saisie', () {
    final mali = TelephoneFormatter(Pays.mali)
        .formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '76123456'));
    expect(mali.text, '76 12 34 56');
    final fr = TelephoneFormatter(france).formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '612345678'));
    expect(fr.text, '6 12 34 56 78');
  });

  test('chaque pays a un drapeau et les pays fréquents existent', () {
    expect(Pays.mali.drapeau, '🇲🇱');
    for (final iso in Pays.diaspora) {
      expect(Pays.parIso(iso), isNotNull, reason: iso);
    }
  });
}
