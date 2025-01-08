import 'package:flutter/material.dart';
import 'models/vcard.dart';

class VCardDetailsPage extends StatelessWidget {
  final VCard vcard;

  const VCardDetailsPage({super.key, required this.vcard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Député'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom : ${vcard.nom}', style: const TextStyle(fontSize: 18)),
            Text('Prénom : ${vcard.prenom}',
                style: const TextStyle(fontSize: 18)),
            Text('Organisation : ${vcard.organisation}',
                style: const TextStyle(fontSize: 18)),
            Text('Poste : ${vcard.poste}',
                style: const TextStyle(fontSize: 18)),
            Text('Téléphone : ${vcard.telephone}',
                style: const TextStyle(fontSize: 18)),
            Text('Email : ${vcard.email}',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
