import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Importa o pacote table_calendar
import 'database_helper.dart'; // Importe seu DatabaseHelper

class TelaChamada extends StatefulWidget {
  final DatabaseHelper dbHelper; // Adicione o DatabaseHelper

  TelaChamada({required this.dbHelper}); // Atualize o construtor

  @override
  _TelaChamadaState createState() => _TelaChamadaState();
}

class _TelaChamadaState extends State<TelaChamada> {
  final List<Map<String, dynamic>> alunos = [
    {'nome': 'Aluno 1', 'presente': false},
    {'nome': 'Aluno 2', 'presente': false},
    {'nome': 'Aluno 3', 'presente': false},
    {'nome': 'Aluno 4', 'presente': false},
  ];

  List<Map<String, dynamic>> professoras = [];
  String? professoraSelecionada;
  DateTime selectedDate = DateTime.now(); // Data selecionada para o calendário

  @override
  void initState() {
    super.initState();
    carregarProfessoras(); // Carregue as professoras ao iniciar a tela
  }

  Future<void> carregarProfessoras() async {
    professoras = await widget.dbHelper.listarProfessoras(); // Carregue as professoras
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chamada de Alunos'),
      ),
      body: Row( // Usa Row para colocar o calendário e a lista lado a lado
        children: [
          // Calendário na lateral esquerda
          Container(
            width: 250, // Largura do calendário
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: selectedDate,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay; // Atualiza a data selecionada
                    });
                  },
                  selectedDayPredicate: (day) {
                    // Retorna true se o dia selecionado for o mesmo que o dia atual
                    return isSameDay(selectedDate, day);
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left),
                    rightChevronIcon: Icon(Icons.chevron_right),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    defaultDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    weekendDecoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Data Selecionada: ${selectedDate.toLocal()}'.split(' ')[0]), // Mostra a data selecionada
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
                          value: alunos[index]['presente'],
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    ),
                    onPressed: _concluirChamada,
                    child: Text('Concluir Chamada', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _concluirChamada() {
    final presentes = alunos.where((aluno) => aluno['presente']).length;
    final total = alunos.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chamada Concluída'),
        content: Text('Presentes: $presentes de $total'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
