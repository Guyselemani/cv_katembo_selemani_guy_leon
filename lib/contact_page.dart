import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> openLink(String value) async {
    final Uri uri = Uri.parse(value);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget contactItem(IconData icon, String title, String value, String link) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => openLink(link),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes coordonnées'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            const Center(
              child: Icon(Icons.contact_page, size: 90, color: Colors.blue),
            ),

            const Center(
              child: Text(
                'Restons en contact !',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 25),

            contactItem(
              Icons.phone,
              'Téléphone',
              '+243 994 297 702',
              'tel:+243994297702',
            ),

            contactItem(
              Icons.email,
              'E-mail',
              'guylalanneselemanimus@gmail.com',
              'mailto:guylalanneselemanimus@gmail.com',
            ),

            contactItem(
              Icons.location_on,
              'Adresse',
              'Goma, Nord-Kivu, RDC',
              'https://maps.google.com/?q=Goma',
            ),

            contactItem(
              Icons.code,
              'GitHub',
              'Guyselemani',
              'https://github.com/Guyselemani',
            ),
          ],
        ),
      ),
    );
  }
}
