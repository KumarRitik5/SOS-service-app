import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../models/resq_message.dart';
import 'message_storage.dart';
import 'notification_service.dart';

/// ConnectivityManager - Handles all P2P mesh networking
/// Uses Nearby Connections API for device discovery and communication
class ConnectivityManager extends ChangeNotifier {
  final Nearby _nearby = Nearby();
  final MessageStorage _storage = MessageStorage();
  final NotificationService _notificationService = NotificationService();

  static const String SERVICE_ID = "com.resqlink.emergency";
  static const Strategy STRATEGY = Strategy
      .P2P_STAR; // ⚡ OPTIMIZED: P2P_STAR for faster discovery & longer range

  // Connection state
  bool _isAdvertising = false;
  bool _isDiscovering = false;
  Set<String> _connectedDevices = {};
  Set<String> _seenMessageIds = {};
  Map<String, int> _connectionRetries = {}; // Track retry attempts per endpoint
  Map<String, DateTime> _lastConnectionAttempt =
      {}; // Track last connection time

  // 🔥 RANGE OPTIMIZATION: Aggressive discovery settings
  Timer? _rediscoveryTimer;
  static const Duration REDISCOVERY_INTERVAL = Duration(
    seconds: 15,
  ); // Re-scan every 15s
  static const int MAX_CONNECTION_RETRIES =
      5; // Try connecting 5 times before giving up
  static const Duration RETRY_BACKOFF = Duration(
    seconds: 3,
  ); // Wait 3s between retries

  // Context for showing in-app alerts
  BuildContext? _appContext;

  // Broadcast state
  Timer? _broadcastTimer;
  ResQMessage? _currentSOSMessage;
  int _broadcastCount = 0;
  static const int MAX_BROADCASTS = 30; // 5 minutes at 10s intervals

  // Getters
  bool get isAdvertising => _isAdvertising;
  bool get isDiscovering => _isDiscovering;
  int get connectedPeerCount => _connectedDevices.length;
  String get connectionStatus {
    if (_connectedDevices.isEmpty && !_isDiscovering) {
      return 'Offline - Start Discovery';
    } else if (_connectedDevices.isEmpty) {
      return 'Searching for Peers...';
    } else {
      return 'Connected to ${_connectedDevices.length} Peer(s)';
    }
  }

  ConnectivityManager() {
    _initializeSeenMessages();
    _notificationService.initialize();
  }

  /// Set the app context for showing in-app alerts
  void setContext(BuildContext context) {
    _appContext = context;
  }

  /// Initialize seen message IDs from storage
  Future<void> _initializeSeenMessages() async {
    final messages = await _storage.getMessages();
    _seenMessageIds = messages.map((m) => m.id).toSet();
  }

  /// Start advertising this device
  Future<bool> startAdvertising() async {
    if (_isAdvertising) return true;

    try {
      final userName = await _storage.getUserName();

      bool result = await _nearby.startAdvertising(
        userName,
        STRATEGY,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: SERVICE_ID,
      );

      _isAdvertising = result;
      notifyListeners();
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting advertising: $e');
      }
      return false;
    }
  }

  /// Start discovering nearby devices
  Future<bool> startDiscovery() async {
    if (_isDiscovering) return true;

    try {
      bool result = await _nearby.startDiscovery(
        await _storage.getUserName(),
        STRATEGY,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: SERVICE_ID,
      );

      _isDiscovering = result;

      // 🔥 RANGE OPTIMIZATION: Start aggressive re-discovery timer
      if (result) {
        _startAggressiveDiscovery();
      }

      notifyListeners();
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting discovery: $e');
      }
      return false;
    }
  }

  /// 🚀 RANGE BOOSTER: Aggressive re-discovery to catch devices that come in/out of range
  void _startAggressiveDiscovery() {
    _rediscoveryTimer?.cancel();
    _rediscoveryTimer = Timer.periodic(REDISCOVERY_INTERVAL, (timer) async {
      if (!_isDiscovering) {
        timer.cancel();
        return;
      }

      if (kDebugMode) {
        print(
          '🔍 Re-scanning for nearby devices... (Connected: ${_connectedDevices.length})',
        );
      }

      // Briefly restart discovery to catch new devices
      try {
        await _nearby.stopDiscovery();
        await Future.delayed(const Duration(milliseconds: 500));
        await _nearby.startDiscovery(
          await _storage.getUserName(),
          STRATEGY,
          onEndpointFound: _onEndpointFound,
          onEndpointLost: _onEndpointLost,
          serviceId: SERVICE_ID,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Re-discovery error: $e');
        }
      }
    });
  }

  /// Stop advertising
  Future<void> stopAdvertising() async {
    try {
      await _nearby.stopAdvertising();
      _isAdvertising = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping advertising: $e');
      }
    }
  }

  /// Stop discovery
  Future<void> stopDiscovery() async {
    try {
      _rediscoveryTimer?.cancel(); // Stop aggressive re-discovery
      await _nearby.stopDiscovery();
      _isDiscovering = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping discovery: $e');
      }
    }
  }

  /// Start both advertising and discovery for mesh networking
  Future<bool> startMeshNetworking() async {
    final advertise = await startAdvertising();
    final discover = await startDiscovery();
    return advertise && discover;
  }

  /// Stop all mesh networking
  Future<void> stopMeshNetworking() async {
    await stopAdvertising();
    await stopDiscovery();
    await _nearby.stopAllEndpoints();
    _connectedDevices.clear();
    notifyListeners();
  }

  /// Callback when endpoint is found
  void _onEndpointFound(
    String endpointId,
    String endpointName,
    String serviceId,
  ) {
    if (kDebugMode) {
      print(
        '📡 Endpoint found: $endpointName (ID: ${endpointId.substring(0, 8)}...)',
      );
    }

    // 🚀 OPTIMIZED: Check if we should retry connection
    final now = DateTime.now();
    final lastAttempt = _lastConnectionAttempt[endpointId];
    final retries = _connectionRetries[endpointId] ?? 0;

    // Skip if we've tried too many times or tried too recently
    if (retries >= MAX_CONNECTION_RETRIES) {
      if (kDebugMode) {
        print('⚠️ Max retries reached for $endpointName, skipping');
      }
      return;
    }

    if (lastAttempt != null && now.difference(lastAttempt) < RETRY_BACKOFF) {
      if (kDebugMode) {
        print('⏳ Waiting before retry for $endpointName');
      }
      return;
    }

    // Update connection tracking
    _lastConnectionAttempt[endpointId] = now;
    _connectionRetries[endpointId] = retries + 1;

    // Automatically request connection with retry tracking
    _nearby.requestConnection(
      endpointName,
      endpointId,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
  }

  /// Callback when endpoint is lost
  void _onEndpointLost(String? endpointId) {
    if (kDebugMode) {
      print('Endpoint lost: $endpointId');
    }
  }

  /// Callback when connection is initiated
  void _onConnectionInitiated(
    String endpointId,
    ConnectionInfo connectionInfo,
  ) {
    if (kDebugMode) {
      print('Connection initiated with: ${connectionInfo.endpointName}');
    }

    // Auto-accept all connections for emergency mesh
    _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayloadReceived,
      onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {},
    );
  }

  /// Callback when connection result is received
  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      _connectedDevices.add(endpointId);

      // 🎉 SUCCESS: Reset retry counter on successful connection
      _connectionRetries[endpointId] = 0;
      _lastConnectionAttempt.remove(endpointId);

      if (kDebugMode) {
        print(
          '✅ Connected to endpoint: ${endpointId.substring(0, 8)}... (Total: ${_connectedDevices.length})',
        );
      }

      // If we have an active SOS, immediately send to new peer
      if (_currentSOSMessage != null) {
        _sendMessageToEndpoint(endpointId, _currentSOSMessage!);
      }

      notifyListeners();
    } else {
      if (kDebugMode) {
        print(
          '❌ Connection failed with endpoint: ${endpointId.substring(0, 8)}... (Retry: ${_connectionRetries[endpointId] ?? 0}/$MAX_CONNECTION_RETRIES)',
        );
      }
      // Keep retry tracking - will retry on next discovery
    }
  }

  /// Callback when disconnected
  void _onDisconnected(String endpointId) {
    _connectedDevices.remove(endpointId);

    // 🔄 RECONNECT OPTIMIZATION: Reset retry counter to allow reconnection
    _connectionRetries.remove(endpointId);
    _lastConnectionAttempt.remove(endpointId);

    if (kDebugMode) {
      print(
        '🔌 Disconnected from endpoint: ${endpointId.substring(0, 8)}... (Remaining: ${_connectedDevices.length})',
      );
    }
    notifyListeners();
  }

  /// Callback when payload is received
  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes != null) {
      try {
        final message = String.fromCharCodes(payload.bytes!);
        final resqMessage = ResQMessage.fromJsonString(message);

        if (kDebugMode) {
          print('📥 Received message: ${resqMessage.id.substring(0, 8)}... from ${resqMessage.name}');
        }

        _handleReceivedMessage(resqMessage, endpointId);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error parsing received message: $e');
        }
        // Silently continue - don't crash on bad messages
      }
    }
  }

  /// Handle received message and relay if new
  Future<void> _handleReceivedMessage(
    ResQMessage message,
    String fromEndpointId,
  ) async {
    try {
      // Check if we've seen this message before
      if (_seenMessageIds.contains(message.id)) {
        if (kDebugMode) {
          print('⏭️  Duplicate message ignored: ${message.id.substring(0, 8)}...');
        }
        return;
      }

      // Mark as seen
      _seenMessageIds.add(message.id);

      // Store the message
      await _storage.saveMessage(message);

      if (kDebugMode) {
        print(
          '🚨 New SOS from ${message.name}: ${message.message} (Hop: ${message.hopCount})',
        );
      }

      // Show emergency notification with sound and vibration
      try {
        await _notificationService.showEmergencyNotification(message);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️  Failed to show notification: $e');
        }
      }

      // Show in-app alert if app is open
      if (_appContext != null && _appContext!.mounted) {
        try {
          await _notificationService.showInAppAlert(_appContext!, message);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️  Failed to show in-app alert: $e');
          }
        }
      }

      // Relay to all other connected devices with incremented hop count (mesh relay)
      final relayMessage = message.incrementHop();
      _relayMessageToOthers(relayMessage, fromEndpointId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling received message: $e');
      }
      // Don't rethrow - keep mesh network running
    }
  }

  /// Relay message to all connected devices except the sender
  void _relayMessageToOthers(ResQMessage message, String excludeEndpointId) {
    for (String endpointId in _connectedDevices) {
      if (endpointId != excludeEndpointId) {
        _sendMessageToEndpoint(endpointId, message);
      }
    }
  }

  /// Send message to a specific endpoint
  Future<void> _sendMessageToEndpoint(
    String endpointId,
    ResQMessage message,
  ) async {
    try {
      final bytes = Uint8List.fromList(message.toJsonString().codeUnits);
      await _nearby.sendBytesPayload(endpointId, bytes);

      if (kDebugMode) {
        print('Sent message to $endpointId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending to endpoint $endpointId: $e');
      }
    }
  }

  /// Broadcast SOS message to all connected peers
  Future<void> broadcastSOSMessage(ResQMessage message) async {
    try {
      _currentSOSMessage = message;
      _broadcastCount = 0;

      // Save our own message
      await _storage.saveMessage(message);
      _seenMessageIds.add(message.id);

      // Send to all currently connected devices
      _broadcastToAll(message);

      // Start periodic broadcast timer (every 10 seconds for 5 minutes)
      _broadcastTimer?.cancel();
      _broadcastTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _broadcastCount++;

        if (_broadcastCount >= MAX_BROADCASTS) {
          timer.cancel();
          _currentSOSMessage = null;
          if (kDebugMode) {
            print('✅ SOS broadcast completed (${_broadcastCount} broadcasts)');
          }
        } else {
          _broadcastToAll(message);
          if (kDebugMode) {
            print('📡 Broadcasting SOS... (${_broadcastCount}/$MAX_BROADCASTS)');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error broadcasting SOS message: $e');
      }
      rethrow; // Rethrow so UI can handle it
    }
  }

  /// Broadcast message to all connected devices
  void _broadcastToAll(ResQMessage message) {
    if (_connectedDevices.isEmpty) {
      if (kDebugMode) {
        print('No connected devices to broadcast to');
      }
      return;
    }

    for (String endpointId in _connectedDevices) {
      _sendMessageToEndpoint(endpointId, message);
    }

    if (kDebugMode) {
      print('Broadcasted to ${_connectedDevices.length} device(s)');
    }
  }

  /// Stop current SOS broadcast
  void stopSOSBroadcast() {
    _broadcastTimer?.cancel();
    _currentSOSMessage = null;
    _broadcastCount = 0;
  }

  @override
  void dispose() {
    _broadcastTimer?.cancel();
    _rediscoveryTimer?.cancel();
    stopMeshNetworking();
    super.dispose();
  }
}
