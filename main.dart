import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class Contact {
  final String name;
  final String phone;
  Contact(this.name, this.phone);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Bulk Sender',
      theme: ThemeData(primarySwatch: Colors.green),
      home: BulkSenderPage(),
    );
  }
}

class BulkSenderPage extends StatefulWidget {
  @override
  _BulkSenderPageState createState() => _BulkSenderPageState();
}

class _BulkSenderPageState extends State<BulkSenderPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _contactsController = TextEditingController();
  List<Contact> _contacts = [];

  void _parseContacts() {
    final lines = _contactsController.text.trim().split('\n');
    _contacts = lines.map((line) {
      final parts = line.split(',');
      if (parts.length >= 2) {
        return Contact(parts[1].trim(), parts[0].trim());
      }
      return null;
    }).whereType<Contact>().toList();
    setState(() {});
  }

  void _sendMessage(Contact contact) async {
    final message = _messageController.text.replaceAll('@name', contact.name);
    final url = 'https://wa.me/${contact.phone}?text=${Uri.encodeComponent(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa membuka WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WhatsApp Bulk Sender')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Template Pesan (gunakan @name untuk nama):'),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              Text('Kontak (format: nomor,nama per baris):'),
              TextField(
                controller: _contactsController,
                maxLines: 6,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _parseContacts,
                child: Text('Tampilkan Kontak'),
              ),
              ..._contacts.map((contact) => ListTile(
                    title: Text(contact.name),
                    subtitle: Text(contact.phone),
                    trailing: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () => _sendMessage(contact),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
