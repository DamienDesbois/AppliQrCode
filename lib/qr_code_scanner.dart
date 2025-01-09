import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'models/vcard.dart';
import 'vcard_details_page.dart';

class QrCodeScanner extends StatelessWidget {
  QrCodeScanner({super.key});
  final MobileScannerController controller = MobileScannerController();

  void _analyzeQRContent(String content) {
    print("\n=== Analyse du contenu du QR Code ===");
    print("Contenu brut complet :");
    print(content);
    print("\nAnalyse ligne par ligne :");
    content.split('\n').forEach((line) {
      print("Ligne : '${line.trim()}'");
    });
  }

  bool _isValidVCard(String content) {
    final isVCard = content.toLowerCase().trim().startsWith('begin:vcard');
    print("\n=== Vérification VCard ===");
    print("Est une VCard valide : $isVCard");
    return isVCard;
  }

  @override
  Widget build(BuildContext context) {
    bool hasScanned = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture capture) async {
          if (hasScanned) return;
          hasScanned = true;
          controller.stop();

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final qrContent = barcode.rawValue;
            if (qrContent != null) {
              _analyzeQRContent(qrContent);

              // Vérification de la VCard
              if (!_isValidVCard(qrContent)) {
                print("Erreur : Ce n'est pas une VCard valide");
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('Erreur'),
                    content: const Text('Le QR Code doit être de type VCard.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          hasScanned = false;
                          controller.start();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }

              try {
                final vcard = VCard.fromRawData(qrContent);

                print("VCard créée avec succès :");
                print("Nom : '${vcard.nom}'");
                print("Prénom : '${vcard.prenom}'");
                print("Organisation : '${vcard.organisation}'");
                print("Email : '${vcard.email}'");
                print("Téléphone : '${vcard.telephone}'");
                print("Website : '${vcard.website}'");

                if (vcard.nom.isEmpty || vcard.prenom.isEmpty) {
                  throw Exception("Le nom ou le prénom est vide");
                }

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => VCardDetailsPage(vcard: vcard),
                  ),
                );
              } catch (e) {
                print("\n=== Erreur lors de la création de la VCard ===");
                print("Message d'erreur : $e");
                print("Stack trace :");
                print(StackTrace.current);

                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('Erreur'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Format de VCard invalide.'),
                        const SizedBox(height: 8),
                        Text(
                          'Détails: ${e.toString()}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          hasScanned = false;
                          controller.start();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }
            }
          }
        },
      ),
    );
  }
}
