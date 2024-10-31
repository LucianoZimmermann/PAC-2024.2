import 'package:flutter/material.dart';
import 'buscar_alunos_page.dart';
import 'cadastrar_aluno_page.dart';
import 'cadastrar_professora_page.dart';
import 'tela_inicial.dart';
import 'tela_chamada.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();

  try {
    await dbHelper.initialize();
    print("Banco de dados inicializado com sucesso.");
  } catch (e) {
    print("Erro ao inicializar o banco de dados: $e");
  }

  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  MyApp({required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Chamada Escolar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TelaInicial(dbHelper: dbHelper),
      routes: {
        '/cadastrarAluno': (context) => CadastrarAlunoPage(dbHelper: dbHelper),
        '/cadastrarProfessora': (context) => CadastrarProfessoraPage(dbHelper: dbHelper),
        '/buscarAlunos': (context) => BuscarAlunosPage(dbHelper: dbHelper),
        '/chamada': (context) => TelaChamada(
          dbHelper: dbHelper,
          onChamadaConcluida: () {
            // Lógica após a chamada ser concluída
          },
        ),
      },
    );
  }
}
