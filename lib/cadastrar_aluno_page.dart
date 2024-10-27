import 'package:flutter/material.dart';
import 'database_helper.dart';

class CadastrarAlunoPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  CadastrarAlunoPage({required this.dbHelper});

  @override
  _CadastrarAlunoPageState createState() => _CadastrarAlunoPageState();
}

class _CadastrarAlunoPageState extends State<CadastrarAlunoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final List<String> diasDaSemana = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira'];
  Map<String, bool> diasSelecionados = {};
  List<Map<String, dynamic>> professoras = [];
  String? professoraSelecionada;

  @override
  void initState() {
    super.initState();
    for (var dia in diasDaSemana) {
      diasSelecionados[dia] = false;
    }
    carregarProfessoras();
  }

  Future<void> carregarProfessoras() async {
    professoras = await widget.dbHelper.listarProfessoras();
    setState(() {});
  }

  Future<void> cadastrarAluno() async {
    String nome = _nomeController.text.trim(); // Remove espaços em branco
    String matricula = _matriculaController.text.trim(); // Remove espaços em branco
    String dias = diasSelecionados.entries.where((entry) => entry.value).map((entry) => entry.key).join(', ');

    if (nome.isNotEmpty && matricula.isNotEmpty && professoraSelecionada != null) {
      try {
        await widget.dbHelper.inserirAluno(nome, matricula, dias, int.parse(professoraSelecionada!));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar aluno: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha todos os campos corretamente.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Aluno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do Aluno'),
            ),
            TextField(
              controller: _matriculaController,
              decoration: InputDecoration(labelText: 'Número de Matrícula'),
            ),
            SizedBox(height: 20),
            Text('Dias da Semana na Instituição:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Expanded(
              child: ListView.builder(
                itemCount: diasDaSemana.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(diasDaSemana[index]),
                    value: diasSelecionados[diasDaSemana[index]],
                    onChanged: (bool? value) {
                      setState(() {
                        diasSelecionados[diasDaSemana[index]] = value ?? false;
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text('Selecione a Professora:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            DropdownButton<String>(
              hint: Text('Escolha a professora'),
              value: professoraSelecionada,
              onChanged: (String? novaProfessora) {
                setState(() {
                  professoraSelecionada = novaProfessora;
                });
              },
              items: professoras.map((prof) {
                return DropdownMenuItem<String>(
                  value: prof['id'].toString(),
                  child: Text(prof['nome']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: cadastrarAluno,
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
