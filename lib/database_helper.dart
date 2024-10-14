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
    try {
      await _connection.open();
      await _createTables();
      print('Conexão estabelecida e tabelas criadas!');
    } catch (e) {
      print('Erro ao conectar ao banco de dados: $e');
    }
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
        professora_id INTEGER REFERENCES professoras(id),
        faltas INTEGER DEFAULT 0  -- Adicionando a coluna de faltas
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

  // Método para listar alunos por ID da professora
  Future<List<Map<String, dynamic>>> listarAlunosPorProfessora(int professoraId) async {
    final resultado = await _connection.mappedResultsQuery(
      '''
      SELECT * FROM alunos WHERE professora_id = @professoraId
      ''',
      substitutionValues: {
        'professoraId': professoraId,
      },
    );
    return resultado.map((row) => row['alunos']!).toList();
  }

  // Novo método para listar alunos por ID da professora e dia da semana
  Future<List<Map<String, dynamic>>> listarAlunosPorProfessoraEDia(int professoraId, String dia) async {
    final resultado = await _connection.mappedResultsQuery('''
      SELECT * FROM alunos
      WHERE professora_id = @professoraId
      AND dias_na_semana ILIKE '%' || @dia || '%'
    ''', substitutionValues: {
      'professoraId': professoraId,
      'dia': dia,
    });
    return resultado.map((row) => row['alunos']!).toList();
  }

  // Novo método para dar falta ao aluno
  Future<void> darFalta(int alunoId) async {
    await _connection.query(
      '''
      UPDATE alunos SET faltas = faltas + 1 WHERE id = @alunoId
      ''',
      substitutionValues: {
        'alunoId': alunoId,
      },
    );
    print('Falta registrada para o aluno com ID: $alunoId');
  }
}
