import 'package:flutter/material.dart';
import 'models/vcard.dart';
import 'services/database_service.dart';

class VCardDetailsPage extends StatefulWidget {
  final VCard vcard;

  const VCardDetailsPage({super.key, required this.vcard});

  @override
  State<VCardDetailsPage> createState() => _VCardDetailsPageState();
}

class _VCardDetailsPageState extends State<VCardDetailsPage> {
  late Future<Map<String, dynamic>?> _verificationFuture;

  @override
  void initState() {
    super.initState();
    _verificationFuture = DatabaseService.verifyDepute(widget.vcard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification du Député'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _verificationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                ],
              ),
            );
          }

          final dbData = snapshot.data;
          // Vérifier si le député a été trouvé dans la base de données
          if (dbData == null || dbData['status'] == 'error') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Député non trouvé dans la base de données',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                  Text('Nom scanné : ${widget.vcard.nom}'),
                  Text('Prénom scanné : ${widget.vcard.prenom}'),
                ],
              ),
            );
          }

          final differences =
              dbData['differences'] as Map<String, dynamic>? ?? {};
          final isValid = differences.isEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statut de la vérification
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isValid
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isValid ? Icons.check_circle : Icons.warning,
                        color: isValid ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isValid
                              ? 'Député vérifié avec succès'
                              : dbData == null
                                  ? 'Député non trouvé dans la base de données'
                                  : 'Divergences détectées avec la base de données',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Informations du QR Code
                const Text(
                  'Informations du QR Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Nom', widget.vcard.nom, differences['nom']),
                _buildInfoRow(
                    'Prénom', widget.vcard.prenom, differences['prenom']),
                _buildInfoRow('Organisation', widget.vcard.organisation, null),
                _buildInfoRow('Poste', widget.vcard.poste, null),
                _buildInfoRow('Téléphone', widget.vcard.telephone, null),
                _buildInfoRow(
                    'Email', widget.vcard.email, differences['email']),

                if (dbData != null && differences.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Informations de la base de données',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...differences.entries.map((diff) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                diff.key.substring(0, 1).toUpperCase() +
                                    diff.key.substring(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Text(' : '),
                            Expanded(
                              flex: 3,
                              child: Text(diff.value['db'],
                                  style: const TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, Map<String, dynamic>? difference) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label : ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: difference != null ? Colors.red : null,
                    ),
                  ),
                ),
                if (difference != null)
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
