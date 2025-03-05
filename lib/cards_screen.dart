import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardsScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  CardsScreen({required this.folderId, required this.folderName});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final data = await dbHelper.getCardsInFolder(widget.folderId);
    setState(() {
      cards = data;
    });
  }

  void _deleteCard(int cardId) async {
    await dbHelper.deleteCard(cardId);
    _loadCards(); // Refresh the screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folderName)),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            child: Column(
              children: [
                Image.network(card['image'], height: 80, fit: BoxFit.cover), // Load Image
                Text(card['name']),
                ElevatedButton(
                  onPressed: () => _deleteCard(card['id']),
                  child: Text("Delete"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
