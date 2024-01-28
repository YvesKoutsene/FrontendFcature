import 'package:flutter/material.dart';
import 'package:frontendfacture/auth/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'FR');

  bool obscurePassword = true;
  bool obscurerePassword = true;

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
      obscurerePassword = !obscurerePassword;
    });
  }

  Future<void> register(BuildContext context) async {
    const String apiUrl = 'http://localhost:8080/costumers/register';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'fullName': fullNameController.text,
          'email': emailController.text,
          'number': number.phoneNumber,
          'password': passwordController.text,
          'rePassword': rePasswordController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Afficher un Snackbar de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enregistrement réussi. Connectez-vous!'),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      } else {
        dynamic responseData = json.decode(response.body);
        String errorMessage = responseData['message'];

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$errorMessage'),
        ));

        print('Erreur lors de l\'inscription : $errorMessage');
        print(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Exception lors de l\'inscription : $e'),
      ));

      print('Exception lors de l\'inscription : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple, Colors.blue],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 70.0),
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
                        'INSCRIPTION',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      buildTextFieldWithIcon(
                        controller: fullNameController,
                        labelText: 'Nom complet',
                        hintText: 'Votre nom et prénom',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 10.0),
                      buildTextFieldWithIcon(
                        controller: emailController,
                        labelText: 'Email',
                        hintText: 'Votre email',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 10.0),
                      buildPhoneNumberInput(),
                      const SizedBox(height: 8),
                      buildTextFieldWithIcon(
                        controller: passwordController,
                        labelText: 'Mot de passe',
                        hintText: 'Entrer mot de passe',
                        icon: Icons.lock,
                        obscureText: obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          child: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                            size: 20.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      buildTextFieldWithIcon(
                        controller: rePasswordController,
                        labelText: 'Confirmation',
                        hintText: 'Confirmez mot de passe',
                        icon: Icons.lock,
                        obscureText: obscurerePassword,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obscurerePassword = !obscurerePassword;
                            });
                          },
                          child: Icon(
                            obscurerePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                            size: 20.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            register(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'S\'INSCRIRE',
                            style:
                                TextStyle(fontSize: 13.0, color: Colors.white),
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
                                  builder: (context) => LoginPage()),
                            );
                          },
                          child: const Text(
                            'Vous avez déjà un compte?',
                            style:
                                TextStyle(color: Colors.black, fontSize: 13.0),
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
    bool obscureText = false,
    Widget? suffixIcon,
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
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget buildPhoneNumberInput() {
    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber number) {
        setState(() {
          this.number = number;
        });
      },
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
      ),
      ignoreBlank: false,
      autoValidateMode: AutovalidateMode.disabled,
      selectorTextStyle: const TextStyle(color: Colors.black),
      initialValue: number,
      formatInput: false,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      inputDecoration: const InputDecoration(
        labelText: 'Téléphone',
        border: OutlineInputBorder(
          borderSide: BorderSide(),
        ),
      ),
    );
  }
}
