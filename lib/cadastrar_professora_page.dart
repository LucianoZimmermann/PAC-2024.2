import 'package:flutter/material.dart';
import 'database_helper.dart';

class CadastrarProfessoraPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  CadastrarProfessoraPage({required this.dbHelper});

  @override
  _CadastrarProfessoraPageState createState() => _CadastrarProfessoraPageState();
}

class _CadastrarProfessoraPageState extends State<CadastrarProfessoraPage> {
  final TextEditingController _nomeProfessoraController = TextEditingController();

  Future<void> cadastrarProfessora() async {
    String nome = _nomeProfessoraController.text.trim(); // Remove espaços em branco
    if (nome.isNotEmpty) {
      try {
        await widget.dbHelper.inserirProfessora(nome);
        Navigator.pop(context);
      } catch (e) {
        // Exibe uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar professora: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nome não pode estar vazio.')));
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
