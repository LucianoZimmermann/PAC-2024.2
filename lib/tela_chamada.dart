import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_helper.dart';

class TelaChamada extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Function onChamadaConcluida;

  TelaChamada({required this.dbHelper, required this.onChamadaConcluida});

  @override
  _TelaChamadaState createState() => _TelaChamadaState();
}

class _TelaChamadaState extends State<TelaChamada> {
  List<Map<String, dynamic>> alunos = [];
  List<Map<String, dynamic>> professoras = [];
  String? professoraSelecionada;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    carregarProfessoras();
  }

  Future<void> carregarProfessoras() async {
    professoras = List<Map<String, dynamic>>.from(await widget.dbHelper.listarProfessoras());
    if (professoras.isNotEmpty) {
      professoraSelecionada = professoras.first['id'].toString();
      carregarAlunos();
    }
    setState(() {});
  }

  Future<void> carregarAlunos() async {
    if (professoraSelecionada != null) {
      final idProfessora = int.parse(professoraSelecionada!);
      alunos = List<Map<String, dynamic>>.from(await widget.dbHelper.listarAlunosPorProfessora(idProfessora));
      setState(() {});
    }
  }

  void _concluirChamada() async {
    for (var aluno in alunos) {
      await widget.dbHelper.registrarPresenca(aluno['id'], selectedDate, aluno['presente']);
    }
    widget.onChamadaConcluida();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chamada de Alunos'),
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now().subtract(Duration(days: 30)),
                  lastDay: DateTime.now(),
                  focusedDay: selectedDate,
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!selectedDay.isAfter(DateTime.now())) {
                      setState(() {
                        selectedDate = selectedDay;
                      });
                    }
                  },
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                ),
                SizedBox(height: 20),
                Text('Data Selecionada: ${selectedDate.toLocal()}'.split(' ')[0]),
              ],
            ),
          ),
          Expanded(
            child: Padding(
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
                      carregarAlunos();
                    },
                    items: professoras.map((prof) {
                      return DropdownMenuItem<String>(
                        value: prof['id'].toString(),
                        child: Text(prof['nome']),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: alunos.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(alunos[index]['nome']),
                          value: alunos[index]['presente'] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              alunos[index]['presente'] = value!;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _concluirChamada,
                    child: Text('Concluir Chamada'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
