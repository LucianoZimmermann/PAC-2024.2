import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amaescola/database_helper.dart';
import 'package:amaescola/main.dart';
import 'package:amaescola/tela_inicial.dart';

void main() {
  testWidgets('Verificar se a AppBar e os botões estão aparecendo corretamente', (WidgetTester tester) async {
    // Criar uma instância do DatabaseHelper (sem inicializar, pois estamos em teste)
    DatabaseHelper dbHelper = DatabaseHelper();

    // Constrói o widget da aplicação e aguarda o frame
    await tester.pumpWidget(MaterialApp(
      home: TelaInicial(dbHelper: dbHelper),
    ));

    // Espera o aplicativo concluir qualquer tarefa pendente de renderização
    await tester.pumpAndSettle();

    // Verifica se o título da AppBar está na tela
    expect(find.text('AMA - Chamada Flexível'), findsOneWidget);

    // Verifica se os botões "Cadastrar Aluno" e "Cadastrar Professora" estão na tela
    expect(find.text('Cadastrar Aluno'), findsOneWidget);
    expect(find.text('Cadastrar Professora'), findsOneWidget);
  });
}
