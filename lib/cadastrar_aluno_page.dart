import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastrarAlunoPage extends StatefulWidget {
  @override
  _CadastrarAlunoPageState createState() => _CadastrarAlunoPageState();
}

class _CadastrarAlunoPageState extends State<CadastrarAlunoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final List<String> diasDaSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira'
  ];
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
    // Obtendo a lista de professoras do Firestore
    final querySnapshot =
        await FirebaseFirestore.instance.collection('professores').get();
    professoras = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'nome': doc['nome'],
      };
    }).toList();
    setState(() {});
  }

  Future<void> cadastrarAluno() async {
    String nome = _nomeController.text.trim();
    String matricula = _matriculaController.text.trim();
    List<String> dias = diasSelecionados.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (nome.isNotEmpty &&
        matricula.isNotEmpty &&
        professoraSelecionada != null) {
      try {
        // Adicionando o aluno na coleção 'alunos' do Firestore
        await FirebaseFirestore.instance.collection('alunos').add({
          'nome': nome,
          'matricula': matricula,
          'dias': dias,
          'professoraId': professoraSelecionada,
          'dataCadastro': FieldValue.serverTimestamp(),
        });
        Navigator.pop(context); // Voltar para a tela anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar aluno: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preencha todos os campos corretamente.')));
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
            Text('Dias da Semana na Instituição:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            Text('Selecione a Professora:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
