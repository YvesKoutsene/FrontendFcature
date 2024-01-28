import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendfacture/pages/dashbord.dart';


class Product {
  final int id;
  final String name;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.price,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Product> selectedProducts = [];
  int? _userID;
  int _totalQuantity = 0; // Nouvelle variable pour la quantité totale

  Future<void> _getUserID() async {
    final preferences = await SharedPreferences.getInstance();
    final userID = preferences.getInt('personId');
    setState(() {
      _userID = userID;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserID();
    _fetchCartQuantity(); // Ajout de l'appel initial pour récupérer la quantité du panier
  }

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/products'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Product> products = data
            .map((json) => Product(
          id: json['productId'],
          name: json['nameProduct'],
          price: json['priceUnit'].toDouble(),
        ))
            .toList();

        return products;
      } else {
        throw Exception('Échec du chargement des produits');
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<void> _showQuantityDialog(Product product) async {
    int quantity = 1;

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Veuillez préciser la quantité :'),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = int.tryParse(value) ?? 1;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _addToCart(product, quantity);
                      Navigator.pop(context);
                    },
                    child: Text('Ajouter'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addToCart(Product product, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/ligne-commande/create'),
        body: {
          'costumerId': _userID != null ? _userID.toString() : '',
          'productId': product.id.toString(),
          'quantity': quantity.toString(),
        },
      );

      if (response.statusCode == 200) {
        await _fetchCartQuantity();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit ajouté au panier avec succès!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception("Échec d'ajout de produit");
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  Future<void> _fetchCartQuantity() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/ligne-commande/countByCustomer/$_userID'),
      );

      if (response.statusCode == 200) {
        final int cartQuantity = int.parse(response.body);
        setState(() {
          _totalQuantity = cartQuantity;
        });
      } else {
        throw Exception("Échec de récupération de la quantité du panier");
      }
    } catch (e) {
      throw Exception('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashBordPage(),
                ),
              );
            },
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 10,
                    child: Text(
                      _totalQuantity.toString(),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder<List<Product>>(
          future: fetchProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else {
              List<Product> products = snapshot.data!;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      _showQuantityDialog(products[index]);
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/shop.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  products[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Prix : \$${products[index].price.toString()}',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.0),
                          IconButton(
                            onPressed: () {
                              _showQuantityDialog(products[index]);
                            },
                            icon: Icon(Icons.shopping_cart),
                            tooltip: 'Ajouter au panier',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
