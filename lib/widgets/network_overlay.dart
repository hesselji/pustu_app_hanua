import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkOverlay extends StatefulWidget {
  final Widget child;

  const NetworkOverlay({super.key, required this.child});

  @override
  State<NetworkOverlay> createState() => _NetworkOverlayState();
}

class _NetworkOverlayState extends State<NetworkOverlay> {
  bool isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  void initState() {
    super.initState();

    /// 🔥 LISTEN NETWORK
    subscription =
        Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection =
          results.any((r) => r != ConnectivityResult.none);

      setState(() {
        isOffline = !hasConnection;
      });
    });

    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();

    final hasConnection =
        results.any((r) => r != ConnectivityResult.none);

    setState(() {
      isOffline = !hasConnection;
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        /// 🔥 OVERLAY (LEBIH STABIL)
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isOffline,
            child: AnimatedOpacity(
              opacity: isOffline ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                children: [
                  /// 🔥 BLUR BACKGROUND
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),

                  /// 🔥 CARD UI (TETAP SAMA)
                  Center(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        decoration: TextDecoration.none, // 🔥 FORCE NO LINE
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off,
                                color: Colors.white, size: 40),

                            const SizedBox(height: 20),

                            const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              "Tidak ada koneksi internet",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration:
                                    TextDecoration.none, // 🔥 DOUBLE SAFE
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Menunggu jaringan kembali...",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                decoration:
                                    TextDecoration.none, // 🔥 DOUBLE SAFE
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}