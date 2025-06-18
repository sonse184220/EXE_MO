import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/signalr_service.dart';

class GlobalSignalRWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalSignalRWrapper({super.key, required this.child});

  @override
  ConsumerState<GlobalSignalRWrapper> createState() => _GlobalSignalRWrapperState();
}

class _GlobalSignalRWrapperState extends ConsumerState<GlobalSignalRWrapper> {
  bool _isConnecting = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initSignalR();
  }

  Future<void> _initSignalR() async {
    setState(() {
      _isConnecting = true;
      _hasError = false;
    });

    try {
      await SignalRService().initConnection();

      // Optional: You can subscribe to other events here
      SignalRService().onMessage((args) {
        // Trigger UI reactions or global notifications
        print("🔔 Received from server: $args");
      });

      setState(() {
        _isConnecting = false;
      });
    } catch (e) {
      debugPrint('❌ SignalR connection failed: $e');
      setState(() {
        _hasError = true;
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isConnecting) {
    //   return const LoadingPage(); // Reuse your consistent loading screen
    // }

    if (_hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFF89B7C2), // SPRING SKY
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF89B7C2), // SPRING SKY
                Color(0xFFA8BF8A), // MEADOW
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        'assets/images/appLogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Error Text
                const Text(
                  "Oops! Can't connect to server.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Check your connection or try again.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB876), // PAPAYA
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _initSignalR,
                  child: const Text(
                    "Retry Connection",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 60),

                // Footer Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'EXE201',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
  // Widget build(BuildContext context) {
  //   if (_isConnecting) {
  //     return const Scaffold(
  //       body: Center(child: CircularProgressIndicator()),
  //     );
  //   }
  //
  //   if (_hasError) {
  //     return Scaffold(
  //       body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             const Text("🚫 Cannot connect to server."),
  //             const SizedBox(height: 16),
  //             ElevatedButton(
  //               onPressed: _initSignalR,
  //               child: const Text("Retry Connection"),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return widget.child;
  // }
}
