import 'package:postgres/postgres.dart';

class DatabaseHelper {
  late PostgreSQLConnection _connection;

  DatabaseHelper() {
    _connection = PostgreSQLConnection(
      'localhost',
      5432,
      'ama',
      username: 'postgres',
      password: '1234',
    );
  }

  Future<void> initialize() async {
    await _connection.open();
    await _createTables();
    print('Conexão estabelecida e tabelas criadas!');
  }

  Future<void> _createTables() async {
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS professoras (
        id SERIAL PRIMARY KEY,
        nome VARCHAR(100) NOT NULL
      );
    ''');

    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS alunos (
        id SERIAL PRIMARY KEY,
        nome VARCHAR(100) NOT NULL,
        matricula VARCHAR(50) NOT NULL UNIQUE,
        dias_na_semana VARCHAR(200),
        professora_id INTEGER REFERENCES professoras(id)
      );
    ''');
  }

  Future<void> inserirProfessora(String nome) async {
    await _connection.query(
      'INSERT INTO professoras (nome) VALUES (@nome)',
      substitutionValues: {'nome': nome},
    );
    print('Professora cadastrada: $nome');
  }

  Future<List<Map<String, dynamic>>> listarProfessoras() async {
    final resultado = await _connection.mappedResultsQuery(
      'SELECT * FROM professoras',
    );
    return resultado.map((row) => row['professoras']!).toList();
  }

  Future<void> inserirAluno(String nome, String matricula, String dias, int professoraId) async {
    await _connection.query(
      '''
      INSERT INTO alunos (nome, matricula, dias_na_semana, professora_id)
      VALUES (@nome, @matricula, @dias, @professoraId)
      ''',
      substitutionValues: {
        'nome': nome,
        'matricula': matricula,
        'dias': dias,
        'professoraId': professoraId,
      },
    );
    print('Aluno cadastrado: $nome');
  }

  Future<List<Map<String, dynamic>>> listarAlunos() async {
    final resultado = await _connection.mappedResultsQuery(
      'SELECT * FROM alunos',
    );
    return resultado.map((row) => row['alunos']!).toList();
  }
}
