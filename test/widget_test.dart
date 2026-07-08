import 'package:flutter_test/flutter_test.dart';

import 'package:projeto/main.dart';

void main() {
  testWidgets('renders game catalog app', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Jogos'), findsOneWidget);
    expect(find.text('Categorias'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Busca'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
  });
}
