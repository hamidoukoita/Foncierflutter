import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';

void main() {
  Widget page(Widget enfant) => MaterialApp(home: Scaffold(body: enfant));

  testWidgets('largeur libre (Positioned sans left) : pas d’erreur de mise en page', (tester) async {
    await tester.pumpWidget(page(const Stack(children: [
      Positioned(right: 8, bottom: 8, child: AppActionButton(label: 'Voir le plan ', icon: Icons.map_outlined)),
    ])));
    expect(tester.takeException(), isNull);
    expect(find.text('Voir le plan '), findsOneWidget);
  });

  testWidgets('largeur imposée : le libellé se tronque sans déborder', (tester) async {
    await tester.pumpWidget(page(const Center(
      child: SizedBox(width: 120, child: AppActionButton(label: 'Construire une maison comme celle-ci', icon: Icons.home)),
    )));
    expect(tester.takeException(), isNull);
  });
}
