import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/nom_personne.dart';

void main() {
  test('accepte les noms en lettres (accents, tiret, apostrophe)', () {
    expect(NomPersonne.valider('Aïssata', libelle: 'Prénom'), isNull);
    expect(NomPersonne.valider("N'Diaye-Traoré", libelle: 'Nom'), isNull);
  });

  test('refuse le vide, les espaces seuls et les chiffres', () {
    expect(NomPersonne.valider('   ', libelle: 'Nom'), 'Nom obligatoire');
    expect(NomPersonne.valider('Moussa2', libelle: 'Prénom'), 'Prénom : lettres uniquement');
    expect(NomPersonne.valider('-Awa', libelle: 'Prénom'), isNotNull);
  });
}
