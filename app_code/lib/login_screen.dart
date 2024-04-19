import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      print("Login failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  Text(
                    'FEUP-reUSE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Título em preto
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'O FEUP-reUSE ajuda-te a partilhar e encontrar recursos reutilizáveis para um mundo mais sustentável.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black, // Descrição em preto
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text('Register'),
            ),
            const SizedBox(height: 32.0), // Aumentando o espaço abaixo dos botões
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Reutilize',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, // Rs em preto
                  ),
                ),
                Text(
                  '.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, // Rs em preto
                  ),
                ),
                Text(
                  ' Reduza',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, // Rs em preto
                  ),
                ),
                Text(
                  '.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, // Rs em preto
                  ),
                ),
                Text(
                  ' Recicle.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, // Rs em preto
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
