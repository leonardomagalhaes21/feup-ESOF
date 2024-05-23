import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'register_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
      _showAlertDialog(context, "Incorrect email or password.");
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
        title: Center(
          child: Text(
            "Login",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontFamily: GoogleFonts.oswald().fontFamily,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: const Column(
                children: [
                  Text(
                    'FEUP-reUSE',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, 
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'FEUP-reUSE helps you share and find reusable resources for a more sustainable world.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black, 
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 10),
              SizedBox(
                width: 200, 
                child: ElevatedButton(
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(color: Colors.white), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                    ),
                  ),
                  child: Text('Login'),
                ),
              ),
              const SizedBox(height: 10), 
              SizedBox(
                width: 200, 
                child: ElevatedButton(
                  onPressed: () { 
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(
                      color: Colors.white, 
                    ),
                    shape: RoundedRectangleBorder( 
                      borderRadius: BorderRadius.circular(8), 
                    ),
                  ),
                  child: Text('Register'),
                ),
              ),
              const SizedBox(height: 10), 
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Reuse',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, 
                  ),
                ),
                Text(
                  '.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, 
                  ),
                ),
                Text(
                  ' Reduce',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, 
                  ),
                ),
                Text(
                  '.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, 
                  ),
                ),
                Text(
                  ' Recycle.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, 
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
