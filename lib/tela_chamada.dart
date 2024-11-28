import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class TelaChamada extends StatefulWidget {
  final Function onChamadaConcluida;

  TelaChamada({required this.onChamadaConcluida});

  @override
  _TelaChamadaState createState() => _TelaChamadaState();
}

class _TelaChamadaState extends State<TelaChamada> {
  List<Map<String, dynamic>> alunos = []; // Use Map to store only data
  List<QueryDocumentSnapshot<Map<String, dynamic>>> professoras = [];
  String? professoraSelecionada;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    carregarProfessoras();
  }

  // Carregar lista de professoras do Firebase Firestore
  Future<void> carregarProfessoras() async {
    final professorasRef = FirebaseFirestore.instance.collection('professores');
    final snapshot = await professorasRef.get();
    professoras =
        snapshot.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
    if (professoras.isNotEmpty) {
      professoraSelecionada = professoras.first.id;
      carregarAlunos();
    }
    setState(() {});
  }

  // Carregar lista de alunos da professora selecionada
  Future<void> carregarAlunos() async {
    if (professoraSelecionada != null) {
      final alunosRef = FirebaseFirestore.instance
          .collection('alunos')
          .where('professoraId', isEqualTo: professoraSelecionada);
      final snapshot = await alunosRef.get();
      alunos =
          snapshot.docs.map((doc) => doc.data()).toList(); // Store only data

      // Carregar as presenças de todos os alunos para a data selecionada
      for (var aluno in alunos) {
        await carregarPresenca(aluno['id']);
      }

      setState(() {});
    }
  }

  // Carregar a presença de um aluno para a data selecionada
  Future<void> carregarPresenca(String alunoId) async {
    final presencaRef = FirebaseFirestore.instance
        .collection('presencas')
        .where('alunoId', isEqualTo: alunoId)
        .where('data', isEqualTo: selectedDate.toIso8601String())
        .limit(1);

    final snapshot = await presencaRef.get();
    if (snapshot.docs.isNotEmpty) {
      final presenca = snapshot.docs.first;
      final alunoIndex = alunos.indexWhere((aluno) => aluno['id'] == alunoId);
      if (alunoIndex != -1) {
        setState(() {
          alunos[alunoIndex]['presente'] = presenca['presente'];
        });
      }
    } else {
      final alunoIndex = alunos.indexWhere((aluno) => aluno['id'] == alunoId);
      if (alunoIndex != -1) {
        setState(() {
          alunos[alunoIndex]['presente'] = false;
        });
      }
    }
  }

  // Registrar presença no Firebase
  void _concluirChamada() async {
    final batch = FirebaseFirestore.instance.batch();
    for (var aluno in alunos) {
      final alunoRef =
          FirebaseFirestore.instance.collection('alunos').doc(aluno['id']);
      final presencaRef =
          FirebaseFirestore.instance.collection('presencas').doc();

      batch.set(presencaRef, {
        'alunoId': aluno['id'],
        'data': selectedDate.toIso8601String(),
        'presente': aluno['presente'] ?? false,
      });
    }
    await batch.commit();
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
                      carregarAlunos(); // Carregar alunos e presenças para a nova data
                    }
                  },
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                ),
                SizedBox(height: 20),
                Text('Data Selecionada: ${selectedDate.toLocal()}'
                    .split(' ')[0]),
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
                        value: prof.id,
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

                              // Atualizando a presença diretamente no Firestore
                              FirebaseFirestore.instance
                                  .collection('presencas')
                                  .doc(alunos[index]['id'])
                                  .update({'presente': value});
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
