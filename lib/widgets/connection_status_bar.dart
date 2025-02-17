import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class ConnectionStatusBar extends StatefulWidget {
  const ConnectionStatusBar({
    super.key,
    required this.baseUrl,
  });

  final String baseUrl;

  static Future<bool> checkConnection(String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  State<ConnectionStatusBar> createState() => _ConnectionStatusBarState();
}

class _ConnectionStatusBarState extends State<ConnectionStatusBar> {
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startHeartbeat();
  }

  @override
  void didUpdateWidget(ConnectionStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseUrl != widget.baseUrl) {
      _startHeartbeat();
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _timeoutTimer?.cancel();
    
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkConnection(),
    );
    
    // Initial check
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    _timeoutTimer?.cancel();
    
    try {
      // Set up timeout timer
      _timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) setState(() => _isConnected = false);
      });

      final isConnected = await ConnectionStatusBar.checkConnection(widget.baseUrl);
      _timeoutTimer?.cancel();
      
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConnected = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isConnected 
              ? 'Connected to API'
              : 'Not connected - Check configuration',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
} 