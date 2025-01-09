import 'package:mysql1/mysql1.dart';
import '../models/vcard.dart';

class DatabaseService {
  static Future<Map<String, dynamic>?> verifyDepute(VCard vcard) async {
    print("=== Début de la vérification ===");
    print("Vérification pour : ${vcard.nom} ${vcard.prenom}");

    MySqlConnection? conn;
    try {
      final settings = ConnectionSettings(
        host: '192.168.10.16',
        port: 3306,
        user: 'desbois_damien',
        password: 'b3jH12VY',
        db: 'desbois_damien_depute',
        timeout: Duration(seconds: 30),
      );

      print("Tentative de connexion à MySQL...");
      conn = await MySqlConnection.connect(settings);
      print("Connexion établie avec succès !");

      // Test simple de la connexion
      print("Test de la connexion...");
      await conn.query('SELECT 1');
      print("Test réussi !");

      print("Exécution de la requête SQL...");
      var results = await conn.query(
          'SELECT d.NOM, d.PRENOM, d.MAIL FROM depute d WHERE UPPER(d.NOM) = ? AND UPPER(d.PRENOM) = ?',
          [vcard.nom.toUpperCase(), vcard.prenom.toUpperCase()]);

      print("Requête exécutée");
      print("Nombre de résultats : ${results.length}");

      if (results.isEmpty) {
        print("Aucun député trouvé");
        return null;
      }

      var depute = results.first;
      print("Député trouvé dans la base");

      // Conversion explicite en Map<String, dynamic>
      return {
        'status': 'success',
        'depute': {
          'nom': depute['NOM']?.toString() ?? '',
          'prenom': depute['PRENOM']?.toString() ?? '',
          'email': depute['MAIL']?.toString() ?? '',
        },
        'differences': <String, dynamic>{}
      };
    } catch (e) {
      print("Erreur : $e");
      print("Stack trace : ${StackTrace.current}");
      return {
        'status': 'error',
        'message': 'Erreur: $e',
        'differences': <String, dynamic>{}
      };
    } finally {
      if (conn != null) {
        try {
          print("Fermeture de la connexion...");
          await conn.close();
          print("Connexion fermée");
        } catch (e) {
          print("Erreur lors de la fermeture : $e");
        }
      }
    }
  }
}
