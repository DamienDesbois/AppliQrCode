class VCard {
  late String nom;
  late String prenom;
  late String organisation;
  late String poste;
  late String telephone;
  late String email;
  late String website;
  String? deputeId;

  // Méthode pour récupérer l'URL de la photo
  String? getPhotoUrl() {
    return deputeId != null
        ? "https://datan.fr/assets/imgs/deputes_webp/depute_${deputeId}_webp.webp"
        : null;
  }

  // Méthode pour définir l'ID du député
  void setDeputeId(String id) {
    deputeId = id;
  }

  VCard.fromRawData(String data) {
    print(data);

    nom = "";
    prenom = "";
    organisation = "";
    poste = "";
    telephone = "";
    email = "";
    website = "";
    deputeId = null; // Initialisation à null

    List<String> lines = data.split('\n');
    for (String line in lines) {
      line = line.trim();
      print("Traitement ligne: '$line'");

      if (line.startsWith('N:')) {
        String namePart = line.substring(2).trim();
        print("Partie nom trouvée: '$namePart'");

        List<String> parts = namePart.split(';');
        print("Parties après split: ${parts.length} parties");
        parts.forEach((part) => print("- '$part'"));

        if (parts.length >= 2) {
          nom = capitalizeFirstLetter(parts[0].trim());
          prenom = capitalizeFirstLetter(parts[1].trim());
          print("Nom extrait: '$nom'");
          print("Prénom extrait: '$prenom'");
        } else {
          print("ERREUR: Pas assez de parties dans le nom");
        }
      } else if (line.startsWith('ORG:')) {
        organisation = line.substring(4).trim();
      } else if (line.startsWith('TITLE:')) {
        poste = line.substring(6).trim();
      } else if (line.startsWith('TEL;')) {
        telephone = line.split(':').last.trim();
      } else if (line.startsWith('EMAIL;')) {
        email = line.split(':').last.trim();
      } else if (line.startsWith('URL:')) {
        website = line.substring(4).trim();
      }
    }

    print("Nom: '$nom'");
    print("Prénom: '$prenom'");
    print("Organisation: '$organisation'");

    if (nom.isEmpty || prenom.isEmpty) {
      print("ERREUR: Nom ou prénom vide");
      throw Exception("Le nom ou le prénom est vide");
    }
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
