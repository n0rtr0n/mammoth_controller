import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class ConnectionStatusBar extends StatefulWidget {
  const ConnectionStatusBar({
    super.key,
    required this.baseUrl,
    required this.currentPatternName,
    required this.currentColorMaskName,
  });

  final String baseUrl;
  final String? currentPatternName;
  final String? currentColorMaskName;

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
      const Duration(seconds: 5),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Connection status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          
          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.currentPatternName != null)
                  Text('Current Pattern: ${widget.currentPatternName}'),
                if (widget.currentColorMaskName != null)
                  Text('Current Color Mask: ${widget.currentColorMaskName}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 