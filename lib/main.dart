import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'cards_screen.dart';

void main() {
  runApp(CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Card Organizer',
      home: FolderScreen(),
    );
  }
}

class FolderScreen extends StatefulWidget {
  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final data = await dbHelper.getFolders();
    setState(() {
      folders = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Card Organizer")),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          return ListTile(
            title: Text(folder['name']),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardsScreen(folderId: folder['id'], folderName: folder['name']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
