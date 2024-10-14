import 'package:flutter/material.dart';
import 'database_helper.dart';

class BuscarAlunosPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  BuscarAlunosPage({required this.dbHelper});

  @override
  _BuscarAlunosPageState createState() => _BuscarAlunosPageState();
}

class _BuscarAlunosPageState extends State<BuscarAlunosPage> {
  List<Map<String, dynamic>> alunos = [];
  List<Map<String, dynamic>> professoras = [];
  String? professoraSelecionada;
  String? diaSelecionado;
  final List<String> diasDaSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira'
  ];

  @override
  void initState() {
    super.initState();
    carregarProfessoras();
  }

  Future<void> carregarProfessoras() async {
    professoras = await widget.dbHelper.listarProfessoras();
    setState(() {});
  }

  Future<void> buscarAlunos() async {
    if (professoraSelecionada != null) {
      final idProfessora = int.parse(professoraSelecionada!);
      alunos = await widget.dbHelper.listarAlunosPorProfessoraEDia(
          idProfessora, diaSelecionado ?? '');
      setState(() {});
    }
  }

  Future<void> registrarFalta(int alunoId) async {
    await widget.dbHelper.darFalta(alunoId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Falta registrada para o aluno!'),
    ));
    // Atualiza a lista de alunos para refletir as alterações
    buscarAlunos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Alunos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            Text('Selecione o dia da semana:'),
            DropdownButton<String>(
              hint: Text('Escolha o dia'),
              value: diaSelecionado,
              onChanged: (String? novoDia) {
                setState(() {
                  diaSelecionado = novoDia;
                });
              },
              items: diasDaSemana.map((dia) {
                return DropdownMenuItem<String>(
                  value: dia,
                  child: Text(dia),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: buscarAlunos,
              child: Text('Buscar Alunos'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: alunos.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(alunos[index]['nome']),
                      subtitle: Text('Matrícula: ${alunos[index]['matricula']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.cancel), // Ícone para registrar falta
                        onPressed: () {
                          registrarFalta(alunos[index]['id']);
                        },
                        tooltip: 'Registrar Falta',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
