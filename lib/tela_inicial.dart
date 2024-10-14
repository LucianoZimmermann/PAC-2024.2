import 'package:flutter/material.dart';
import 'database_helper.dart';

class TelaInicial extends StatelessWidget {
  final DatabaseHelper dbHelper;

  TelaInicial({required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Cor de fundo cinza
      appBar: AppBar(
        title: Text('AMA - Chamada Flexível'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Cor do botão
                foregroundColor: Colors.white, // Cor do texto do botão
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Aumenta o padding
                textStyle: TextStyle(
                  fontSize: 18, // Aumenta o tamanho do texto
                  fontWeight: FontWeight.bold, // Deixa o texto em negrito
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/cadastrarAluno');
              },
              child: Text('Cadastrar Aluno'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Cor do botão
                foregroundColor: Colors.white, // Cor do texto do botão
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Aumenta o padding
                textStyle: TextStyle(
                  fontSize: 18, // Aumenta o tamanho do texto
                  fontWeight: FontWeight.bold, // Deixa o texto em negrito
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/cadastrarProfessora');
              },
              child: Text('Cadastrar Professora'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Cor do botão
                foregroundColor: Colors.white, // Cor do texto do botão
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Aumenta o padding
                textStyle: TextStyle(
                  fontSize: 18, // Aumenta o tamanho do texto
                  fontWeight: FontWeight.bold, // Deixa o texto em negrito
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/buscarAlunos');
              },
              child: Text('Chamada'),
            ),
          ],
        ),
      ),
    );
  }
}
