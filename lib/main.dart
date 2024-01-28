import 'package:flutter/material.dart';
import 'package:frontendfacture/auth/register.dart';
import 'package:frontendfacture/auth/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PresentationPage(),
    );
  }
}

class PresentationPage extends StatefulWidget {
  const PresentationPage({Key? key}) : super(key: key);

  @override
  _PresentationPageState createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.blue],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Bienvenue sur Ayélévie\'Shop',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              FadeTransition(
                opacity: _fadeAnimation,
                child: ElevatedButton(
                  onPressed: () {
                    _showRegistrationWidget();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    textStyle: TextStyle(fontSize: 17),
                  ),
                  child: Text('Commencer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegistrationWidget() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(32.0), //16.0
          //color: Colors.yellowAccent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Redirection vers la page d'inscription
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey, // Couleur de fond du bouton
                  onPrimary: Colors.white, // Couleur du texte du bouton
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Inscription'),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: TextButton.styleFrom(
                  primary: Colors.blue, // Couleur du texte du bouton
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  textStyle: TextStyle(fontSize: 14),
                ),
                child: Text('Vous avez déja un compte?'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
