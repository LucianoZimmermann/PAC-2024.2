import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastrarProfessoraPage extends StatefulWidget {
  @override
  _CadastrarProfessoraPageState createState() =>
      _CadastrarProfessoraPageState();
}

class _CadastrarProfessoraPageState extends State<CadastrarProfessoraPage> {
  final TextEditingController _nomeProfessoraController =
      TextEditingController();

  // Função para cadastrar a professora no Firestore
  Future<void> cadastrarProfessora() async {
    String nome = _nomeProfessoraController.text.trim();
    if (nome.isNotEmpty) {
      try {
        // Adicionando a professora na coleção 'professores'
        await FirebaseFirestore.instance.collection('professores').add({
          'nome': nome,
          'dataCadastro': FieldValue.serverTimestamp(),
        });
        Navigator.pop(context); // Voltar para a tela anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar professora: $e')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Nome não pode estar vazio.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Professora'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeProfessoraController,
              decoration: InputDecoration(labelText: 'Nome da Professora'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: cadastrarProfessora,
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
