import 'package:postgres/postgres.dart';

class DatabaseHelper {
  late PostgreSQLConnection _connection;

  DatabaseHelper() {
    _connection = PostgreSQLConnection(
      'localhost',
      5432,
      'ama',
      username: 'postgres',
      password: '241505',
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
    await _connection.execute('DROP TABLE IF EXISTS presencas;');
    await _connection.execute('DROP TABLE IF EXISTS alunos;');
    await _connection.execute('DROP TABLE IF EXISTS professoras;');

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
        dias_na_semana TEXT[] NOT NULL,
        id_professora INTEGER REFERENCES professoras(id)
      );
    ''');

    await _connection.execute(''' 
      CREATE TABLE IF NOT EXISTS presencas (
        id SERIAL PRIMARY KEY,
        id_aluno INTEGER REFERENCES alunos(id),
        data DATE NOT NULL,
        presente BOOLEAN NOT NULL
      );
    ''');
  }

  Future<List> listarProfessoras() async {
    final List<Map<String, dynamic>> professoras = await _connection.mappedResultsQuery('SELECT * FROM professoras');
    return professoras.map((p) => p.values.first).toList();
  }

  Future<List> listarAlunosPorProfessora(int idProfessora) async {
    final List<Map<String, dynamic>> alunos = await _connection.mappedResultsQuery(
      'SELECT * FROM alunos WHERE id_professora = @idProfessora',
      substitutionValues: {'idProfessora': idProfessora},
    );
    return alunos.map((a) => a.values.first).toList();
  }

  Future<void> inserirAluno(String nome, String matricula, List<String> dias, int idProfessora) async {
    await _connection.execute(''' 
      INSERT INTO alunos (nome, matricula, dias_na_semana, id_professora) 
      VALUES (@nome, @matricula, @dias, @idProfessora)
    ''', substitutionValues: {
      'nome': nome,
      'matricula': matricula,
      'dias': dias,
      'idProfessora': idProfessora,
    });
  }

  Future<List> listarPresencasPorAluno(int alunoId) async {
    final List<Map<String, dynamic>> presencas = await _connection.mappedResultsQuery(
      'SELECT * FROM presencas WHERE id_aluno = @idAluno',
      substitutionValues: {'idAluno': alunoId},
    );
    return presencas.map((p) => p.values.first).toList();
  }

  Future<void> registrarPresenca(int idAluno, DateTime data, bool presente) async {
    await _connection.execute(''' 
      INSERT INTO presencas (id_aluno, data, presente) VALUES (@idAluno, @data, @presente)
    ''', substitutionValues: {
      'idAluno': idAluno,
      'data': data,
      'presente': presente,
    });
  }

  Future<void> inserirProfessora(String nome) async {
    await _connection.execute(''' 
      INSERT INTO professoras (nome) VALUES (@nome)
    ''', substitutionValues: {
      'nome': nome,
    });
  }
}
