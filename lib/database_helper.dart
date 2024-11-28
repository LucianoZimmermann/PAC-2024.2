import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert'; // Importando para trabalhar com JSON

class DatabaseHelper {
  static Database? _database;

  // Define os nomes das tabelas
  static const String TABLE_PROFESSORES = 'professores';
  static const String TABLE_ALUNOS = 'alunos';
  static const String TABLE_PRESENCAS = 'presencas';

  // Define os campos da tabela `professores`
  static const String COLUMN_ID = 'id';
  static const String COLUMN_NOME = 'nome';

  // Define os campos da tabela `alunos`
  static const String COLUMN_MATRICULA = 'matricula';
  static const String COLUMN_DIA_SEMANA =
      'diaSemana'; // Alterar para string JSON

  // Define os campos da tabela `presencas`
  static const String COLUMN_ALUNO_ID = 'alunoId';
  static const String COLUMN_DATA = 'data';
  static const String COLUMN_PRESENTE = 'presente';

  // Função para inicializar o banco de dados
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // Criação do banco de dados
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 2, // Incrementando a versão para permitir alterações no banco
      onCreate: (db, version) async {
        // Criação da tabela `professores`
        await db.execute('''
          CREATE TABLE $TABLE_PROFESSORES(
            $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COLUMN_NOME TEXT
          )
        ''');

        // Criação da tabela `alunos` com `diaSemana` armazenado como JSON
        await db.execute('''
          CREATE TABLE $TABLE_ALUNOS(
            $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COLUMN_MATRICULA INTEGER,
            $COLUMN_NOME TEXT,
            $COLUMN_DIA_SEMANA TEXT
          )
        ''');

        // Criação da tabela `presencas`
        await db.execute('''
          CREATE TABLE $TABLE_PRESENCAS(
            $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COLUMN_ALUNO_ID INTEGER,
            $COLUMN_DATA TEXT,
            $COLUMN_PRESENTE INTEGER,
            FOREIGN KEY($COLUMN_ALUNO_ID) REFERENCES $TABLE_ALUNOS($COLUMN_ID)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Alterações no banco de dados quando a versão for 2
          // Exemplo de como adicionar uma coluna, se necessário:
          // await db.execute('''ALTER TABLE $TABLE_ALUNOS ADD COLUMN $COLUMN_DIA_SEMANA TEXT''');
        }
      },
    );
  }

  // Função para inserir um professor
  Future<int> insertProfessor(Map<String, dynamic> professor) async {
    final db = await database;
    return await db.insert(TABLE_PROFESSORES, professor);
  }

  // Função para inserir um aluno
  Future<int> insertAluno(Map<String, dynamic> aluno) async {
    final db = await database;

    // Convertendo a lista `diaSemana` para uma string JSON antes de salvar
    aluno[COLUMN_DIA_SEMANA] = jsonEncode(aluno[COLUMN_DIA_SEMANA]);

    return await db.insert(TABLE_ALUNOS, aluno);
  }

  // Função para inserir uma presença
  Future<int> insertPresenca(Map<String, dynamic> presenca) async {
    final db = await database;
    return await db.insert(TABLE_PRESENCAS, presenca);
  }

  // Função para obter todos os professores
  Future<List<Map<String, dynamic>>> getAllProfessores() async {
    final db = await database;
    return await db.query(TABLE_PROFESSORES);
  }

  // Função para obter todos os alunos
  Future<List<Map<String, dynamic>>> getAllAlunos() async {
    final db = await database;
    var alunos = await db.query(TABLE_ALUNOS);

    // Convertendo a string JSON de volta para lista de `diaSemana`
    for (var aluno in alunos) {
      try {
        aluno[COLUMN_DIA_SEMANA] = aluno[COLUMN_DIA_SEMANA] =
            aluno[COLUMN_DIA_SEMANA] != null
                ? (aluno[COLUMN_DIA_SEMANA]
                    as String) // Se o valor não for nulo, converte para String
                : ''; // Caso contrário, atribui uma string vazia
      } catch (e) {
        // Em caso de erro na conversão, atribuímos uma lista vazia
        aluno[COLUMN_DIA_SEMANA] = [];
      }
    }

    return alunos;
  }

  // Função para obter as presenças de um aluno
  Future<List<Map<String, dynamic>>> getPresencasPorAluno(int alunoId) async {
    final db = await database;
    return await db.query(
      TABLE_PRESENCAS,
      where: '$COLUMN_ALUNO_ID = ?',
      whereArgs: [alunoId],
    );
  }

  // Função para atualizar a presença de um aluno
  Future<int> updatePresenca(int id, Map<String, dynamic> presenca) async {
    final db = await database;
    return await db.update(
      TABLE_PRESENCAS,
      presenca,
      where: '$COLUMN_ID = ?',
      whereArgs: [id],
    );
  }

  // Função para excluir uma presença
  Future<int> deletePresenca(int id) async {
    final db = await database;
    return await db.delete(
      TABLE_PRESENCAS,
      where: '$COLUMN_ID = ?',
      whereArgs: [id],
    );
  }

  // Função para fechar o banco de dados
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
