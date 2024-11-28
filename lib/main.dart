import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importando o Firestore
import 'firebase_options.dart'; // Importando as opções geradas pelo Firebase CLI
import 'buscar_alunos_page.dart';
import 'cadastrar_aluno_page.dart';
import 'cadastrar_professora_page.dart';
import 'tela_inicial.dart';
import 'tela_chamada.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;

  // Inicialize o Firebase com as configurações corretas
  try {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions.currentPlatform, // Usando as opções geradas
    );
    print("Firebase inicializado com sucesso.");
    isFirebaseInitialized = true; // Marca como inicializado com sucesso
  } catch (e) {
    print("Erro ao inicializar o Firebase: $e");
    // Se não conseguir inicializar o Firebase, o valor de isFirebaseInitialized será false
  }

  // Passando o estado de inicialização do Firebase para o MyApp
  runApp(MyApp(isFirebaseInitialized: isFirebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseInitialized;

  const MyApp({Key? key, required this.isFirebaseInitialized})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Chamada Escolar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isFirebaseInitialized
          ? TelaInicial(
              firebaseFirestore:
                  FirebaseFirestore.instance) // Passando o Firestore
          : Scaffold(
              body: Center(child: Text('Erro ao inicializar o Firebase!')),
            ),
      routes: {
        '/cadastrarAluno': (context) => CadastrarAlunoPage(),
        '/cadastrarProfessora': (context) => CadastrarProfessoraPage(),
        '/buscarAlunos': (context) => BuscarAlunosPage(),
        '/chamada': (context) => TelaChamada(
              onChamadaConcluida: () {
                // Lógica após a chamada ser concluída
              },
            ),
      },
    );
  }
}
