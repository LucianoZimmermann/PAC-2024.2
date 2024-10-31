import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  Map<int, bool> expandidos = {};
  Map<int, List<Map<String, dynamic>>> presencasPorAluno = {};
  DateTime selectedDate = DateTime.now();
  List<String> diasBloqueados = [];

  @override
  void initState() {
    super.initState();
    carregarProfessoras();
  }

  Future<void> carregarProfessoras() async {
    try {
      professoras = List<Map<String, dynamic>>.from(await widget.dbHelper.listarProfessoras());
      setState(() {});
    } catch (e) {
      print("Erro ao carregar professoras: $e");
    }
  }

  Future<void> buscarAlunos() async {
    if (professoraSelecionada != null) {
      final idProfessora = int.parse(professoraSelecionada!);
      try {
        alunos = List<Map<String, dynamic>>.from(await widget.dbHelper.listarAlunosPorProfessora(idProfessora));
        for (var aluno in alunos) {
          expandidos[aluno['id']] = false;
          presencasPorAluno[aluno['id']] = [];
        }
        setState(() {});
      } catch (e) {
        print("Erro ao buscar alunos: $e");
      }
    }
  }

  Future<void> carregarPresencas(int alunoId) async {
    try {
      final presencas = await widget.dbHelper.listarPresencasPorAluno(alunoId);
      setState(() {
        presencasPorAluno[alunoId] = List<Map<String, dynamic>>.from(presencas);
        diasBloqueados = presencas.expand((p) => List<String>.from(p['dias_na_semana'] ?? [])).toSet().toList();
      });
    } catch (e) {
      print("Erro ao carregar presenças: $e");
    }
  }

  Widget buildPresenca(int alunoId) {
    List<Map<String, dynamic>> presencas = presencasPorAluno[alunoId] ?? [];
    return TableCalendar(
      firstDay: DateTime.now().subtract(Duration(days: 30)),
      lastDay: DateTime.now(),
      focusedDay: selectedDate,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, events) {
          bool? presente = presencas.any((p) => DateTime.parse(p['dia']).isAtSameMomentAs(date) && p['presente']);
          Color cor = presente == true ? Colors.green : (date.isAfter(DateTime.now()) ? Colors.grey : Colors.red);
          return Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
            child: Center(
              child: diasBloqueados.contains(date.weekdayToString()) ? Icon(Icons.lock, color: Colors.red) : null,
            ),
          );
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        if (!selectedDay.isAfter(DateTime.now()) && !diasBloqueados.contains(selectedDay.weekdayToString())) {
          setState(() {
            selectedDate = selectedDay;
          });
        }
      },
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar Alunos')),
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
                buscarAlunos();
              },
              items: professoras.map((prof) {
                return DropdownMenuItem<String>(
                  value: prof['id'].toString(),
                  child: Text(prof['nome']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: buscarAlunos, child: Text('Buscar Alunos')),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: alunos.length,
                itemBuilder: (context, index) {
                  final aluno = alunos[index];
                  return ExpansionTile(
                    title: Text(aluno['nome']),
                    initiallyExpanded: expandidos[aluno['id']] ?? false,
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        expandidos[aluno['id']] = expanded;
                      });
                      if (expanded) {
                        carregarPresencas(aluno['id']);
                      }
                    },
                    children: [buildPresenca(aluno['id'])],
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

extension DateTimeExtension on DateTime {
  String weekdayToString() {
    switch (this.weekday) {
      case 1: return 'Segunda-feira';
      case 2: return 'Terça-feira';
      case 3: return 'Quarta-feira';
      case 4: return 'Quinta-feira';
      case 5: return 'Sexta-feira';
      default: return '';
    }
  }
}
