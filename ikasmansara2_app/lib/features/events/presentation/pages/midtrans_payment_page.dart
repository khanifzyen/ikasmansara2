import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

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

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
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
      context.go('/tiketku');
    } else {
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/tiketku');
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
