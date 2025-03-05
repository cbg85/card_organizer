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

  Future<void> _addCard() async {
    if (cards.length >= 6) {
      _showMessage("This folder can only hold 6 cards.");
      return;
    }
    await dbHelper.addCard("Card ${cards.length + 1}", widget.folderName, "image_url", widget.folderId);
    _loadCards();
  }

  Future<void> _deleteCard(int cardId) async {
    await dbHelper.deleteCard(cardId);
    _loadCards();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.folderName} Cards")),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(card['name']),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteCard(card['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addCard,
      ),
    );
  }
}
