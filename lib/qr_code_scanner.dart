import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'models/vcard.dart';
import 'vcard_details_page.dart';

class QrCodeScanner extends StatelessWidget {
  QrCodeScanner({super.key});
  final MobileScannerController controller = MobileScannerController();

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
          controller.stop(); // Arrêter le scanner immédiatement

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final qrContent = barcode.rawValue;
            if (qrContent != null) {
              // Vérifier si c'est une VCard valide
              if (!qrContent.toLowerCase().startsWith('begin:vcard')) {
                await showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Empêche la fermeture en cliquant à côté
                  builder: (context) => AlertDialog(
                    title: const Text('Erreur'),
                    content: const Text('Le QR Code doit être de type VCard.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          hasScanned = false;
                          controller
                              .start(); // Redémarrer le scanner uniquement après OK
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => VCardDetailsPage(vcard: vcard),
                  ),
                );
              } catch (e) {
                await showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Empêche la fermeture en cliquant à côté
                  builder: (context) => AlertDialog(
                    title: const Text('Erreur'),
                    content: const Text('Format de VCard invalide.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          hasScanned = false;
                          controller
                              .start(); // Redémarrer le scanner uniquement après OK
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
