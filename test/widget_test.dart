import 'package:flutter_test/flutter_test.dart';
import 'package:ecosolar/main.dart';

void main() {
  testWidgets('app starts', (t) async {
    await t.pumpWidget(const EcoSolarApp());
  });
}
