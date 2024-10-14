import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'tela_inicial.dart'; // Importe a TelaInicial
import 'cadastrar_aluno_page.dart'; // Importe a tela de cadastro de aluno
import 'cadastrar_professora_page.dart'; // Importe a tela de cadastro de professora
import 'buscar_alunos_page.dart'; // Importe a tela de buscar alunos

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();

  // Tente inicializar o banco de dados
  try {
    await dbHelper.initialize();
    print("Banco de dados inicializado com sucesso.");
  } catch (e) {
    print("Erro ao inicializar o banco de dados: $e");
    // Aqui você pode adicionar uma lógica para lidar com erros de inicialização,
    // como exibir uma tela de erro ou uma mensagem ao usuário.
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
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.blueAccent,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black),
        ),
      ),
      home: TelaInicial(dbHelper: dbHelper),
      routes: {
        '/cadastrarAluno': (context) => CadastrarAlunoPage(dbHelper: dbHelper),
        '/cadastrarProfessora': (context) => CadastrarProfessoraPage(dbHelper: dbHelper),
        '/buscarAlunos': (context) => BuscarAlunosPage(dbHelper: dbHelper),
      },
    );
  }
}
