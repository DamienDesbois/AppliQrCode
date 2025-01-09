import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/vcard.dart';

class DatabaseService {
  static Future<Map<String, dynamic>?> verifyDepute(VCard vcard) async {
    try {
      final response = await http.post(
          Uri.parse('http://192.168.141.1/hackathon/apiConnexion.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'nom': vcard.nom, 'prenom': vcard.prenom}));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("Réponse de l'API: $result");
        return result;
      } else {
        print("Erreur HTTP: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erreur de connexion: $e");
      return null;
    }
  }
}
