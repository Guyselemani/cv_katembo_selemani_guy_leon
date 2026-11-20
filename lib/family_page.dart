import 'package:flutter/material.dart';

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  final List<Map<String, String>> family = const [
    {
      'name': 'MUSUBAO Christian',
      'relation': 'Père',
      'photo': 'assets/papa.jpeg',
    },
    {
      'name': 'Nabudukuli Mpaka',
      'relation': 'Mère',
      'photo': 'assets/maman.jpeg',
    },
    {
      'name': 'Evans Selemani',
      'relation': 'Frère',
      'photo': 'assets/evan.jpeg',
    },
    {
      'name': 'Aime Selemani',
      'relation': 'Sœur',
      'photo': 'assets/aime.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma famille'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: family.length,
        itemBuilder: (context, index) {
          final member = family[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 15),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(member['photo']!),
              ),
              title: Text(
                member['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(member['relation']!),
            ),
          );
        },
      ),
    );
  }
}
