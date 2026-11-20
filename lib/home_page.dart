import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget infoCard(String title, String description) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(6),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/profil.jpeg'),
          ),
        ),
        title: const Text('Mon curriculum vitæ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 65,
                    backgroundImage: AssetImage('assets/profil.jpeg'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'GUY SELEMANI',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Étudiant en informatique',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),

            sectionTitle('À propos de moi'),
            const Text(
              'Je suis Katembo Selemani Guy Leon, étudiant à l’Institut supérieur d’informatique et de gestion (ISIG Goma). '
              'Mon rêve est de devenir entrepreneur et d’apporter une solution à la pauvreté et au chômage dans mon pays, la RDC. '
              'Je prie Dieu de me donner la force de réaliser mes rêves afin de créer des emplois pour les jeunes sans emploi et de leur offrir une vie meilleure.',
              style: TextStyle(fontSize: 16),
            ),

            sectionTitle('Formation'),
            infoCard(
              'Informatique',
              'Études en informatique à l’ISIG Goma, de 2023 à 2027.',
            ),

            sectionTitle('Expériences et projets'),
            infoCard(
              'Projet de développement',
              'Création de petits projets en HTML, CSS, JavaScript et Flutter.',
            ),
            infoCard(
              'Projet professionnel',
              'Gestion et organisation d’activités de services.',
            ),

            sectionTitle('Compétences techniques'),
            infoCard(
              'Programmation',
              'HTML, CSS, JavaScript, Dart et Flutter.',
            ),
            infoCard(
              'Outils informatiques',
              'Microsoft Word, Excel, Git et GitHub.',
            ),

            sectionTitle('Langues'),
            infoCard('Français', 'Bonne communication.'),
            infoCard('Swahili', 'Bonne communication.'),

            sectionTitle('Centres d’intérêt'),
            infoCard(
              'Loisirs',
              'Informatique, nouvelles technologies, football et musique.',
            ),
          ],
        ),
      ),
    );
  }
}
