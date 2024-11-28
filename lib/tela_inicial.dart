import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaInicial extends StatelessWidget {
  final FirebaseFirestore firebaseFirestore;

  // Construtor recebendo o FirebaseFirestore
  TelaInicial({required this.firebaseFirestore});

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
