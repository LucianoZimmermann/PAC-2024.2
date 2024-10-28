import 'package:flutter/material.dart';
import 'cadastrar_aluno_page.dart';
import 'cadastrar_professora_page.dart';
import 'buscar_alunos_page.dart';
import 'tela_chamada.dart';
import 'database_helper.dart';

class TelaInicial extends StatelessWidget {
  final DatabaseHelper dbHelper;

  TelaInicial({required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('AMA - Chamada Flexível'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cadastrarAluno');
              },
              child: Text('Cadastrar Aluno'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cadastrarProfessora');
              },
              child: Text('Cadastrar Professora'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/buscarAlunos');
              },
              child: Text('Buscar Aluno'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chamada');
              },
              child: Text('Chamada'),
            ),
          ],
        ),
      ),
    );
  }
}
