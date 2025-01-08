class VCard {
  final String nom;
  final String prenom;
  final String organisation;
  final String poste;
  final String telephone;
  final String email;

  VCard({
    required this.nom,
    required this.prenom,
    required this.organisation,
    required this.poste,
    required this.telephone,
    required this.email,
  });

  factory VCard.fromRawData(String rawData) {
    final lines = rawData.replaceAll('\r\n', '\n').split('\n');
    String nom = '',
        prenom = '',
        organisation = '',
        poste = '',
        telephone = '',
        email = '';

    for (var line in lines) {
      print('Analyse ligne: $line');

      if (line.startsWith('N:')) {
        final parts = line.substring(2).split(';');
        nom = parts[0];
        prenom = parts[1];
      } else if (line.startsWith('ORG:')) {
        organisation = line.substring(4);
      } else if (line.startsWith('TEL;WORK;VOICE:')) {
        telephone = line.substring('TEL;WORK;VOICE:'.length).trim();
      } else if (line.startsWith('EMAIL;WORK;INTERNET:')) {
        email = line.substring('EMAIL;WORK;INTERNET:'.length).trim();
      }
    }

    return VCard(
      nom: nom,
      prenom: prenom,
      organisation: organisation,
      poste: poste,
      telephone: telephone,
      email: email,
    );
  }

  @override
  String toString() {
    return '''
    Nom: $nom
    Prénom: $prenom
    Email: $email
    Organisation: $organisation
    Poste: $poste
    Téléphone: $telephone
    ''';
  }
}
