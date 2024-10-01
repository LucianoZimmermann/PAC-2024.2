import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.initialize();

  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  MyApp({required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Chamada Escolar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TelaInicial(dbHelper: dbHelper),
      routes: {
        '/cadastrarAluno': (context) => CadastrarAlunoPage(dbHelper: dbHelper),
        '/cadastrarProfessora': (context) => CadastrarProfessoraPage(dbHelper: dbHelper),
      },
    );
  }
}

class TelaInicial extends StatelessWidget {
  final DatabaseHelper dbHelper;

  TelaInicial({required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ],
        ),
      ),
    );
  }
}

class CadastrarProfessoraPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  CadastrarProfessoraPage({required this.dbHelper});

  @override
  _CadastrarProfessoraPageState createState() => _CadastrarProfessoraPageState();
}

class _CadastrarProfessoraPageState extends State<CadastrarProfessoraPage> {
  final TextEditingController _nomeProfessoraController = TextEditingController();

  Future<void> cadastrarProfessora() async {
    String nome = _nomeProfessoraController.text;
    if (nome.isNotEmpty) {
      await widget.dbHelper.inserirProfessora(nome);
      Navigator.pop(context);
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
              onPressed: () async {
                String dias = diasSelecionados.entries.where((entry) => entry.value).map((entry) => entry.key).join(', ');
                if (professoraSelecionada != null) {
                  await widget.dbHelper.inserirAluno(
                    _nomeController.text,
                    _matriculaController.text,
                    dias,
                    int.parse(professoraSelecionada!),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
