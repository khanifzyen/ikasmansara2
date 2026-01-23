import 'package:url_launcher/url_launcher.dart';

class ContactSeller {
  Future<void> call({required String whatsappNumber, String? message}) async {
    // Format number: Ensure it starts with country code (e.g., 62), remove '+' or '0' prefix if needed
    // Simple logic: If starts with '0', replace with '62'.
    var phone = whatsappNumber.replaceAll(
      RegExp(r'\D'),
      '',
    ); // Remove non-digits

    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    final Uri url = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message ?? "Halo, saya tertarik dengan produk Anda di IKA SMANSARA Marketplace.")}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch WhatsApp');
    }
  }
}
