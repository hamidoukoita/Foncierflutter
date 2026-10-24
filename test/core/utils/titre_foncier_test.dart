import 'package:flutter_mobile_prospect_agent/core/utils/titre_foncier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TitreFoncier', () {
    test('ajoute le préfixe TF- à la référence', () {
      expect(TitreFoncier.complet('1024/Kati'), 'TF-1024/Kati');
      expect(TitreFoncier.complet('  BKO-10294 '), 'TF-BKO-10294');
    });

    test('ne double pas un préfixe déjà tapé', () {
      expect(TitreFoncier.complet('tf 1024 / Kati'), 'TF-1024 / Kati');
      expect(TitreFoncier.complet('TF-BKO-10294'), 'TF-BKO-10294');
      expect(TitreFoncier.complet('T.F. n°1024'), 'TF-1024');
    });

    test('exige une référence', () {
      expect(TitreFoncier.valider(''), isNotNull);
      expect(TitreFoncier.valider('TF-'), isNotNull);
      expect(TitreFoncier.valider('/12'), isNotNull);
      expect(TitreFoncier.valider('1024'), isNull);
    });
  });
}
