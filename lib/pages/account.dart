import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendfacture/main.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Ajoutez les variables
  String fullName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final storedFullName = preferences.getString('fullName') ?? '';
    final storedEmail = preferences.getString('email') ?? '';

    setState(() {
      this.fullName = storedFullName;
      this.email = storedEmail;
    });
  }

  // Fonction de déconnexion
  Future<void> _logout() async {
    final preferences = await SharedPreferences.getInstance();

    // Supprimez toutes les données stockées dans le local storage
    await preferences.clear();

    // Redirigez vers la première page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PresentationPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Ajoutez une icône account stylisée
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 4),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Affichez les informations de l'utilisateur avec un style personnalisé
            Text(
              'Nom: $fullName',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black38,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black38,
              ),
            ),

            SizedBox(height: 20),
            // Ajoutez un bouton de déconnexion stylisé
            ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.exit_to_app),
              label: Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
