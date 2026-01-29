import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MidtransPaymentPage extends StatefulWidget {
  final String paymentUrl;
  final String bookingId;
  final bool fromEventDetail;

  const MidtransPaymentPage({
    super.key,
    required this.paymentUrl,
    required this.bookingId,
    this.fromEventDetail = false,
  });

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'BlobDownloader',
        onMessageReceived: (JavaScriptMessage message) {
          _saveAndShareFile(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();

            // Handle Blob URLs (QRIS Image)
            if (url.startsWith('blob:')) {
              _handleBlobUrl(request.url);
              return NavigationDecision.prevent;
            }

            // Check for success/finish callback
            if (url.contains('status_code=200') ||
                url.contains('transaction_status=settlement') ||
                url.contains('transaction_status=capture')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }

            // Check for pending callback
            if (url.contains('transaction_status=pending')) {
              _handlePaymentPending();
              return NavigationDecision.prevent;
            }

            // Check for failed/cancelled callback
            if (url.contains('status_code=201') ||
                url.contains('transaction_status=deny') ||
                url.contains('transaction_status=cancel') ||
                url.contains('transaction_status=expire')) {
              _handlePaymentFailed();
              return NavigationDecision.prevent;
            }

            // Handle Image Links / Deep Links
            if (url.endsWith('.png') ||
                url.endsWith('.jpg') ||
                url.endsWith('.jpeg') ||
                url.contains('/qr-code') ||
                url.contains('gojek://') || // Deep links
                url.contains('shopeeid://') ||
                url.contains('wikibit://')) {
              // Open in external app/browser
              launchUrl(
                Uri.parse(request.url),
                mode: LaunchMode.externalApplication,
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _handleBlobUrl(String url) async {
    final script =
        '''
      var xhr = new XMLHttpRequest();
      xhr.open('GET', '$url', true);
      xhr.responseType = 'blob';
      xhr.onload = function(e) {
        if (this.status == 200) {
          var blob = this.response;
          var reader = new FileReader();
          reader.readAsDataURL(blob);
          reader.onloadend = function() {
            var base64data = reader.result;
            BlobDownloader.postMessage(base64data);
          }
        }
      };
      xhr.send();
    ''';
    await _controller.runJavaScript(script);
  }

  Future<void> _saveAndShareFile(String dataUrl) async {
    try {
      // Data URL format: "data:image/png;base64,....."
      final commaIndex = dataUrl.indexOf(',');
      if (commaIndex == -1) return;

      final base64Data = dataUrl.substring(commaIndex + 1);
      final bytes = base64Decode(base64Data);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/payment_qris.png');
      await file.writeAsBytes(bytes);

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'QRIS Pembayaran'),
        );
      }
    } catch (e) {
      debugPrint('Error saving blob: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mengunduh gambar')));
      }
    }
  }

  void _handlePaymentSuccess() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      _navigateToMyTickets();
    }
  }

  void _handlePaymentPending() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran pending. Silakan selesaikan pembayaran.'),
          backgroundColor: Colors.orange,
        ),
      );
      _navigateToMyTickets();
    }
  }

  void _handlePaymentFailed() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran gagal atau dibatalkan.'),
          backgroundColor: Colors.red,
        ),
      );
      _navigateToMyTickets();
    }
  }

  void _navigateToMyTickets() {
    if (widget.fromEventDetail) {
      context.go('/tickets');
    } else {
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/tickets');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran - ${widget.bookingId}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Tutup Pembayaran?'),
                content: const Text(
                  'Anda akan dialihkan ke halaman Tiketku. '
                  'Jika belum bayar, Anda bisa melanjutkan nanti.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _navigateToMyTickets();
                    },
                    child: const Text('Ya, Ke Tiketku'),
                  ),
                ],
              ),
            );
          },
        ),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: WebViewWidget(
        controller: _controller,
        // Enable scrolling gestures
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(),
          ),
        },
      ),
    );
  }
}
