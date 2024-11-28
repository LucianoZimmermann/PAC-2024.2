import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amaescola/tela_inicial.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Criação de um mock do FirebaseFirestore para evitar chamadas reais
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  testWidgets('Verificar se a AppBar e os botões estão aparecendo corretamente',
      (WidgetTester tester) async {
    // Criar o mock do FirebaseFirestore
    MockFirebaseFirestore mockFirestore = MockFirebaseFirestore();

    // Constrói o widget da aplicação e aguarda o frame
    await tester.pumpWidget(MaterialApp(
      home: TelaInicial(
          firebaseFirestore:
              mockFirestore), // Passa o mock do FirebaseFirestore
      routes: {
        '/cadastrarAluno': (_) => Scaffold(body: Text('Cadastrar Aluno')),
        '/cadastrarProfessora': (_) =>
            Scaffold(body: Text('Cadastrar Professora')),
        '/buscarAlunos': (_) => Scaffold(body: Text('Buscar Aluno')),
        '/chamada': (_) => Scaffold(body: Text('Chamada')),
      },
    ));

    // Espera o aplicativo concluir qualquer tarefa pendente de renderização
    await tester.pumpAndSettle();

    // Verifica se o título da AppBar está na tela
    expect(find.text('AMA - Chamada Flexível'), findsOneWidget);

    // Verifica se os botões "Cadastrar Aluno" e "Cadastrar Professora" estão na tela
    expect(find.text('Cadastrar Aluno'), findsOneWidget);
    expect(find.text('Cadastrar Professora'), findsOneWidget);

    // Verifica se os botões são interativos (ou seja, se podem ser pressionados)
    expect(find.byType(ElevatedButton),
        findsNWidgets(2)); // Verifica se há 2 botões

    // Testa a navegação
    await tester.tap(find.text('Cadastrar Aluno'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastrar Aluno'), findsOneWidget);

    await tester.tap(find.text('Cadastrar Professora'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastrar Professora'), findsOneWidget);

    await tester.tap(find.text('Buscar Aluno'));
    await tester.pumpAndSettle();
    expect(find.text('Buscar Aluno'), findsOneWidget);

    await tester.tap(find.text('Chamada'));
    await tester.pumpAndSettle();
    expect(find.text('Chamada'), findsOneWidget);
  });
}
