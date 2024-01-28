import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class LigneCommandeDetails {
  final int ligneCommandeId;
  final double quantity;
  final String nomProduit;
  final double prixProduit;

  LigneCommandeDetails({
    required this.ligneCommandeId,
    required this.quantity,
    required this.nomProduit,
    required this.prixProduit,
  });
}

class DashBordPage extends StatefulWidget {
  @override
  _DashBordPageState createState() => _DashBordPageState();
}

class _DashBordPageState extends State<DashBordPage> {
  late int _customerId;
  String email = '';
  String number = '';
  List<LigneCommandeDetails> lignesDeCommande = [];

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    final preferences = await SharedPreferences.getInstance();
    final customerId = preferences.getInt('personId');
    final storedEmail = preferences.getString('email') ?? '';
    final storedNumber = preferences.getString('number') ?? '';


    if (customerId != null) {
      setState(() {
        _customerId = customerId;
        this.email = storedEmail;
        this.number = storedNumber;
      });
    } else {
      // Gérer le cas où l'ID du client n'est pas disponible
    }
  }

  Future<List<LigneCommandeDetails>> fetchLignesDeCommande(int customerId) async {
    final response = await http.get(Uri.parse('http://localhost:8080/ligne-commande/client/$customerId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<LigneCommandeDetails> lignesDeCommande = data
          .map((json) => LigneCommandeDetails(
        ligneCommandeId: json['ligneCommandeId'],
        quantity: json['quantity'],
        nomProduit: json['nomProduit'],
        prixProduit: json['prixProduit'],
      ))
          .toList();
      return lignesDeCommande;
    } else {
      throw Exception('Échec du chargement des lignes de commande');
    }
  }

  Future<void> _sendInvoice(int customerId) async {
    try {
      // Déclencher le début de l'effet de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Envoi de la facture en cours...'),
              ],
            ),
          );
        },
      );

      final response = await http.get(Uri.parse('http://localhost:8080/pdf/$customerId'));

      // Fermer la boîte de dialogue de chargement
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Facture envoyée sur le courriel $email'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5), // Vous pouvez ajuster la durée selon vos besoins
          ),
        );
      } else {
        // Échec
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de l\'envoi de la facture'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5), // Vous pouvez ajuster la durée selon vos besoins
          ),
        );
      }
    } catch (e) {
      // Gérer les erreurs lors de l'appel de l'API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi de la facture'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteLigneCommande(int ligneCommandeId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/ligne-commande/$ligneCommandeId'),
      );

      if (response.statusCode == 200) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ligne de commande supprimée avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Mettre à jour l'affichage après la suppression
        setState(() {
          lignesDeCommande.removeWhere((ligne) => ligne.ligneCommandeId == ligneCommandeId);
        });
      } else {
        // Échec
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la suppression de la ligne de commande'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Gérer les erreurs lors de l'appel de l'API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression de la ligne de commande'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendInvoiceWhat(int customerId) async {
    try {
      // Déclencher le début de l'effet de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Envoi de la facture en cours...'),
              ],
            ),
          );
        },
      );

      final response = await http.get(Uri.parse('http://localhost:8080/invoices/sendWhatsapp/$customerId'));

      // Fermer la boîte de dialogue de chargement
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Facture envoyée sur le numéro $number'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5), // Vous pouvez ajuster la durée selon vos besoins
          ),
        );
      } else {
        // Échec
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de l\'envoi de la facture'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5), // Vous pouvez ajuster la durée selon vos besoins
          ),
        );
      }
    } catch (e) {
      // Gérer les erreurs lors de l'appel de l'API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi de la facture'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: FutureBuilder<List<LigneCommandeDetails>>(
        future: fetchLignesDeCommande(_customerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune commande disponible'));
          } else {
            lignesDeCommande = snapshot.data!;

            return ListView.builder(
              itemCount: lignesDeCommande.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(lignesDeCommande[index].ligneCommandeId.toString()),
                  onDismissed: (direction) {
                    // Supprimer l'élément lorsque l'utilisateur fait glisser
                    _deleteLigneCommande(lignesDeCommande[index].ligneCommandeId);
                    setState(() {
                      lignesDeCommande.removeAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Produit: ${lignesDeCommande[index].nomProduit}'),
                      subtitle: Text('Quantité: ${lignesDeCommande[index].quantity.toString()}'),
                      trailing: Text('Prix: ${lignesDeCommande[index].prixProduit.toString()}'),
                    ),
                  ),
                );
              },
            );

          }
        },
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: Icon(Icons.email),
            backgroundColor: Colors.blue,
            label: 'Envoyer facture par Mail',
            onTap: () {
              _sendInvoice(_customerId);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.send),
            backgroundColor: Colors.green,
            label: 'Envoyer facture par whatsapp',
            onTap: () {
              _sendInvoiceWhat(_customerId);
            },
          ),
        ],
      ),
    );
  }
}
