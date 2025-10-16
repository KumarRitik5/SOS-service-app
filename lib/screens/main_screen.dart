import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/resq_message.dart';
import '../services/connectivity_manager.dart';
import '../services/location_service.dart';
import '../services/message_storage.dart';
import 'message_list_screen.dart';
import 'settings_screen.dart';

/// MainScreen - Primary interface with SOS button and status display
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final MessageStorage _storage = MessageStorage();
  final Uuid _uuid = const Uuid();
  final TextEditingController _messageController = TextEditingController();

  bool _isSending = false;
  String _statusMessage = '';
  String _userName = 'Emergency User';

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _messageController.text = 'SOS - Emergency! Need help immediately!';

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Load user name
    final name = await _storage.getUserName();
    setState(() {
      _userName = name;
    });

    // Request permissions
    await _requestPermissions();

    // Start mesh networking
    final connectivityManager = Provider.of<ConnectivityManager>(
      context,
      listen: false,
    );

    // Set context for in-app alerts
    connectivityManager.setContext(context);

    await connectivityManager.startMeshNetworking();
  }

  Future<void> _requestPermissions() async {
    // Request all necessary permissions
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
    ].request();
  }

  Future<void> _sendSOS() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
      _statusMessage = 'Getting location...';
    });

    try {
      // Get current location
      final position = await _locationService.getPositionWithFallback();

      if (position == null) {
        setState(() {
          _statusMessage = 'Failed to get location';
          _isSending = false;
        });
        _showErrorDialog('Unable to get your location. Please enable GPS.');
        return;
      }

      // Create SOS message with custom text
      final message = ResQMessage(
        id: _uuid.v4(),
        name: _userName,
        lat: position.latitude,
        lon: position.longitude,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        message: _messageController.text.trim().isEmpty
            ? 'SOS - Emergency!'
            : _messageController.text.trim(),
        hopCount: 0,
      );

      // Broadcast via mesh network
      final connectivityManager = Provider.of<ConnectivityManager>(
        context,
        listen: false,
      );
      await connectivityManager.broadcastSOSMessage(message);

      setState(() {
        _statusMessage = 'SOS sent successfully!';
        _isSending = false;
      });

      _showSuccessDialog('SOS message broadcasted to nearby devices!');
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to send SOS';
        _isSending = false;
      });
      _showErrorDialog('Error sending SOS: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade800],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Success',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Colors.grey.shade900,
              Colors.red.shade900.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(),

              Expanded(
                child: Consumer<ConnectivityManager>(
                  builder: (context, connectivityManager, child) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // User Profile Card
                            _buildUserCard(),

                            const SizedBox(height: 24),

                            // Connection Status Card
                            _buildStatusCard(connectivityManager),

                            const SizedBox(height: 32),

                            // Message Input Card
                            _buildMessageInputCard(),

                            const SizedBox(height: 24),

                            // Quick Message Buttons
                            _buildQuickButtons(),

                            const SizedBox(height: 40),

                            // Animated SOS Button
                            _buildSOSButton(),

                            const SizedBox(height: 20),

                            // Status Message
                            if (_statusMessage.isNotEmpty)
                              _buildStatusMessage(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade900.withOpacity(0.5), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade900],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.emergency, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Text(
            'ResQLink',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
              shadows: [Shadow(color: Colors.red, blurRadius: 10)],
            ),
          ),
          const Spacer(),
          _buildIconButton(Icons.list_alt, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MessageListScreen(),
              ),
            );
          }, 'Messages'),
          const SizedBox(width: 8),
          _buildIconButton(Icons.settings, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900.withOpacity(0.3),
            Colors.purple.shade900.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 15),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISPLAY NAME',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_user, color: Colors.green.shade400, size: 28),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ConnectivityManager manager) {
    final isConnected = manager.connectedPeerCount > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConnected
              ? [
                  Colors.green.shade900.withOpacity(0.3),
                  Colors.teal.shade900.withOpacity(0.2),
                ]
              : [
                  Colors.orange.shade900.withOpacity(0.3),
                  Colors.red.shade900.withOpacity(0.2),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? Colors.green.withOpacity(0.4)
              : Colors.orange.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? Colors.green : Colors.orange).withOpacity(
              0.3,
            ),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isConnected
                    ? [Colors.green.shade600, Colors.green.shade800]
                    : [Colors.orange.shade600, Colors.orange.shade800],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? Colors.green : Colors.orange)
                      .withOpacity(0.5),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MESH NETWORK',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  manager.connectionStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade800],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${manager.connectedPeerCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade900.withOpacity(0.3),
            Colors.indigo.shade900.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.message,
                color: Colors.white.withOpacity(0.8),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'EMERGENCY MESSAGE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              controller: _messageController,
              maxLength: 200,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Describe your emergency...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'QUICK MESSAGES',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildQuickMessageButton(
                'Medical Help 🚑',
                'Need Medical Help - Urgent!',
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickMessageButton(
                'Trapped 🆘',
                'Trapped - Need immediate rescue!',
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildQuickMessageButton(
          'Fire Emergency 🔥',
          'Fire emergency - evacuating now!',
          Colors.deepOrange,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSOSButton() {
    return ScaleTransition(
      scale: _isSending ? _scaleAnimation : _pulseAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          if (!_isSending) {
            _scaleController.forward();
          }
        },
        onTapUp: (_) {
          if (!_isSending) {
            _scaleController.reverse();
            _sendSOS();
          }
        },
        onTapCancel: () {
          if (!_isSending) {
            _scaleController.reverse();
          }
        },
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: _isSending
                  ? [
                      Colors.orange.shade400,
                      Colors.red.shade700,
                      Colors.red.shade900,
                    ]
                  : [
                      Colors.red.shade400,
                      Colors.red.shade700,
                      Colors.red.shade900,
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.6),
                blurRadius: 40,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 80,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                ),
              ),
              // Middle ring
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
              ),
              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSending)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 4,
                      ),
                    )
                  else
                    const Icon(
                      Icons.emergency_share,
                      color: Colors.white,
                      size: 60,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                    ),
                  const SizedBox(height: 12),
                  Text(
                    _isSending ? 'SENDING...' : 'SOS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade800.withOpacity(0.5),
            Colors.purple.shade800.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _statusMessage,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMessageButton(
    String label,
    String message,
    Color color, {
    bool fullWidth = false,
  }) {
    return Expanded(
      flex: fullWidth ? 1 : 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _messageController.text = message;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color.withOpacity(0.4)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
