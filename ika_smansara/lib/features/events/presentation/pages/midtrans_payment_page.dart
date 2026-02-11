import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/network/pb_client.dart';
import '../../../../core/constants/app_breakpoints.dart';
import '../bloc/my_tickets_bloc.dart';

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
  WebViewController? _controller;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isLoading = true;
  double _progress = 0;
  bool _browserOpened = false;

  @override
  void initState() {
    super.initState();
    if (!_isDesktopPlatform()) {
      _initWebViewController();
    }
  }

  bool _isDesktopPlatform() {
    try {
      return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'QrisDownloader',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('🔗 QRIS URL received from JS: ${message.message}');
          _downloadQrisFromUrl(message.message);
        },
      )
      ..addJavaScriptChannel(
        'QrisLogger',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('📜 [JS Log] ${message.message}');
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
            _injectSnapDownloadIntercept();
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();

            if (url.contains('status_code=200') ||
                url.contains('transaction_status=settlement') ||
                url.contains('transaction_status=capture')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=pending')) {
              _handlePaymentPending();
              return NavigationDecision.prevent;
            }

            if (url.contains('status_code=201') ||
                url.contains('transaction_status=deny') ||
                url.contains('transaction_status=cancel') ||
                url.contains('transaction_status=expire')) {
              _handlePaymentFailed();
              return NavigationDecision.prevent;
            }

            if (url.endsWith('.png') ||
                url.endsWith('.jpg') ||
                url.endsWith('.jpeg') ||
                url.contains('/qr-code') ||
                url.contains('gojek://') ||
                url.contains('shopeeid://') ||
                url.contains('wikibit://')) {
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

  Future<void> _injectSnapDownloadIntercept() async {
    final script = '''
      (function() {
        console.log('[Snap] Injecting download interceptor...');
        QrisLogger.postMessage('Injector started');
        
        document.addEventListener('click', function(e) {
          var target = e.target;
          var tagName = target.tagName;
          var text = (target.textContent || target.innerText || '').substring(0, 50);
          var className = target.className || '';
          
          QrisLogger.postMessage('Click: ' + tagName + ' | Text: ' + text);
          
          var isDownloadClick = false;
          var elem = target;
          
          if (tagName === 'BUTTON' || tagName === 'A' || tagName === 'SPAN' || target.parentElement) {
            if (tagName !== 'BUTTON' && tagName !== 'A') {
              elem = target.parentElement;
            }
            
            var elemText = (elem.textContent || elem.innerText || '').toLowerCase();
            var elemClass = (elem.className || '').toLowerCase();
            
            if (elemText.includes('download') || 
                elemText.includes('unduh') ||
                elemClass.includes('download')) {
              isDownloadClick = true;
            }
          }
          
          if (isDownloadClick) {
            e.preventDefault();
            e.stopPropagation();
            
            QrisLogger.postMessage('Download button clicked!');
            
            var allImages = document.querySelectorAll('img');
            QrisLogger.postMessage('Total images: ' + allImages.length);
            
            var qrisImg = null;
            
            for (var i = 0; i < allImages.length; i++) {
              var img = allImages[i];
              var src = img.src || '';
              var alt = (img.alt || '').toLowerCase();
              var className = (img.className || '').toLowerCase();
              
              QrisLogger.postMessage('Img ' + i + ': src=' + src.substring(0, 80) + '... alt=' + alt);
              
              if (src.includes('midtrans.com/v4/qris') || 
                  src.includes('qris') && src.includes('gopay') ||
                  alt === 'qr-code' ||
                  alt.includes('qris') ||
                  className.includes('qris')) {
                qrisImg = img;
                QrisLogger.postMessage('Found QRIS image at index ' + i);
              }
            }
            
            if (qrisImg && qrisImg.src) {
              QrisLogger.postMessage('QRIS URL: ' + qrisImg.src);
              
              if (qrisImg.src.startsWith('blob:')) {
                QrisLogger.postMessage('Blob URL, converting...');
                fetch(qrisImg.src)
                  .then(resp => resp.blob())
                  .then(blob => {
                    var reader = new FileReader();
                    reader.readAsDataURL(blob);
                    reader.onloadend = function() {
                      QrisDownloader.postMessage(reader.result);
                    };
                  })
                  .catch(err => {
                    QrisLogger.postMessage('Fetch error: ' + err);
                  });
              } else {
                QrisLogger.postMessage('Sending URL to Flutter: ' + qrisImg.src);
                QrisDownloader.postMessage(qrisImg.src);
              }
            } else {
              QrisLogger.postMessage('QRIS image not found');
            }
          }
        }, true);
        
        QrisLogger.postMessage('Interceptor injected');
      })();
    ''';

    try {
      await _controller?.runJavaScript(script);
      debugPrint('✅ Snap download interceptor injected');
    } catch (e) {
      debugPrint('❌ Error injecting interceptor: $e');
    }
  }

  Future<void> _downloadQrisFromUrl(String dataUrlOrUrl) async {
    try {
      Uint8List imageBytes;

      if (dataUrlOrUrl.startsWith('data:')) {
        final commaIndex = dataUrlOrUrl.indexOf(',');
        if (commaIndex == -1) {
          debugPrint('Invalid data URL format');
          return;
        }
        final base64Data = dataUrlOrUrl.substring(commaIndex + 1);
        imageBytes = base64Decode(base64Data);
        debugPrint('📥 Received base64 data, size: ${imageBytes.length} bytes');
      } else if (dataUrlOrUrl.startsWith('http')) {
        debugPrint('🔥 Downloading QRIS from: $dataUrlOrUrl');

        final response = await http.get(Uri.parse(dataUrlOrUrl));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
          debugPrint('📥 Downloaded image, size: ${imageBytes.length} bytes');
        } else {
          throw Exception('Failed to download: ${response.statusCode}');
        }
      } else {
        debugPrint('Unknown URL format: $dataUrlOrUrl');
        return;
      }

      if (imageBytes.isEmpty) {
        throw Exception('Empty image bytes');
      }

      final filename = 'qris_${widget.bookingId}.png';

      debugPrint('💾 Saving to gallery with name: $filename');
      await Gal.putImageBytes(imageBytes, name: filename);

      debugPrint('✅ QRIS saved to gallery');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QRIS tersimpan!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(filename, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error downloading QRIS: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Screenshot',
              textColor: Colors.white,
              onPressed: () => _downloadQrisScreenshot(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _downloadQrisScreenshot() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) {
        throw Exception('Failed to capture screenshot');
      }

      await Gal.putImageBytes(image, name: 'qris_${widget.bookingId}.png');

      debugPrint('✅ QRIS screenshot saved to gallery');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QRIS tersimpan di Gallery'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving QRIS: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan QRIS. Silakan screenshot manual.'),
            backgroundColor: Colors.red,
          ),
        );
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
    // Trigger refresh on the singleton MyTicketsBloc
    final userId = _getUserId();
    if (userId != null) {
      GetIt.I<MyTicketsBloc>().add(GetMyBookings(userId));
    }

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

  String? _getUserId() {
    // Get userId from PBClient
    try {
      // ignore: depend_on_referenced_packages
      return GetIt.I<PBClient>().pb.authStore.record?.id;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktopPlatform()) {
      return _buildDesktopPaymentUI();
    }
    return _buildWebViewPaymentUI();
  }

  Widget _buildDesktopPaymentUI() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran - ${widget.bookingId}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCloseConfirmationDialog(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppBreakpoints.maxFormWidth),
          child: Card(
            margin: EdgeInsets.all(
              MediaQuery.sizeOf(context).width >= 840 ? 32 : 24,
            ),
            child: Padding(
              padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width >= 840 ? 32 : 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.payment, size: 64, color: Colors.blue),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).width >= 840 ? 24 : 16,
                  ),
                  const Text(
                    'Pembayaran Midtrans',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).width >= 840 ? 16 : 12,
                  ),
                  Text(
                    'Booking ID: ${widget.bookingId}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).width >= 840 ? 32 : 24,
                  ),
                  const Text(
                    'Pembayaran akan dibuka di browser default Anda. '
                    'Setelah menyelesaikan pembayaran, kembali ke aplikasi '
                    'dan klik tombol di bawah untuk memeriksa status.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).width >= 840 ? 32 : 24,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _browserOpened ? null : _openPaymentInBrowser,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Buka Pembayaran di Browser'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.sizeOf(context).width >= 840
                              ? 16
                              : 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).width >= 840 ? 16 : 12,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _checkPaymentStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Saya Sudah Bayar'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.sizeOf(context).width >= 840
                              ? 16
                              : 12,
                        ),
                      ),
                    ),
                  ),
                  if (_browserOpened) ...[
                    SizedBox(
                      height: MediaQuery.sizeOf(context).width >= 840 ? 16 : 12,
                    ),
                    const Text(
                      'Browser telah dibuka. Silakan selesaikan pembayaran.',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewPaymentUI() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran - ${widget.bookingId}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showCloseConfirmationDialog();
          },
        ),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: WebViewWidget(
          controller: _controller!,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
            ),
          },
        ),
      ),
    );
  }

  Future<void> _openPaymentInBrowser() async {
    final uri = Uri.parse(widget.paymentUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (launched) {
      setState(() {
        _browserOpened = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka browser. Silakan buka manual.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkPaymentStatus() {
    final userId = _getUserId();
    if (userId != null) {
      GetIt.I<MyTicketsBloc>().add(GetMyBookings(userId));
    }

    _navigateToMyTickets();
  }

  void _showCloseConfirmationDialog() {
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
  }
}
