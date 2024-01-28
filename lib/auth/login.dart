import 'package:flutter/material.dart';
import 'package:frontendfacture/auth/register.dart';
import 'package:frontendfacture/layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({Key? key, required this.controller}) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          hintText: 'Votre mot de passe',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
              size: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    const String apiUrl = 'http://localhost:8080/costumers/login02';

    try {
      final Map<String, String> requestData = {
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final personId = responseData['customerId'];
        final fullName = responseData['fullName'] ?? '';
        final number = responseData['number'] ?? '';
        final rePassword = responseData['rePassword'] ?? '';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentification réussie avec succès!'),
            duration: Duration(seconds: 3),
          ),
        );

        final preferences = await SharedPreferences.getInstance();
        preferences.setInt('id', personId);
        preferences.setString('email', _emailController.text);
        preferences.setString('password', _passwordController.text);
        preferences.setInt('personId', personId);
        preferences.setString('fullName', fullName);
        preferences.setString('number', number);
        preferences.setString('repassword', rePassword);
        preferences.setBool('isLoggedIn', true);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LayoutPage()),
          (route) => false,
        );
      } else {
        dynamic responseData = json.decode(response.body);
        String errorMessage = responseData['message'] ?? 'Erreur inconnue';

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$errorMessage'),
        ));

        print('$errorMessage');
        print(response.body);
      }
    } catch (e) {
      print('Exception lors de l\'authentification : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString('email');
    final password = preferences.getString('password');

    setState(() {
      _emailController.text = email ?? '';
      _passwordController.text = password ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.blue]
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 130.0),
              Card(
                color: Colors.white,
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 10.0),
                      const Text(
                        'CONNEXION',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      buildTextFieldWithIcon(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Votre email',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 20.0),
                      PasswordField(controller: _passwordController),
                      const SizedBox(height: 15.0),
                      Container(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                          ),
                          child: const Text(
                            'Mot de passe oublié?',
                            style: TextStyle(color: Colors.black, fontSize: 13.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            login(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'SE CONNECTER',
                            style: TextStyle(fontSize: 13.0, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'S\'ENREGISTRER',
                            style: TextStyle(
                                color: Colors.deepPurple, fontSize: 13.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextFieldWithIcon({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
