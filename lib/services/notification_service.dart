import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/resq_message.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Request notification permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  Future<void> showEmergencyNotification(ResQMessage message) async {
    if (!_isInitialized) await initialize();

    // Play emergency sound
    await _playEmergencySound();

    // Vibrate device
    await _vibrateDevice();

    // Show notification
    final androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Alerts',
      channelDescription: 'Emergency SOS notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ongoing: true,
      autoCancel: false,
      color: Colors.red,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        message.message,
        contentTitle: '🆘 EMERGENCY: ${message.name}',
        summaryText: 'ResQLink Emergency Alert',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'emergency.wav',
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      message.hashCode,
      '🆘 EMERGENCY ALERT',
      '${message.name}: ${message.message}',
      details,
      payload: message.id,
    );
  }

  Future<void> _playEmergencySound() async {
    try {
      // Play default system alarm sound (RingtoneType.alarm is loud and attention-grabbing)
      // The notification system will handle the actual sound via playSound: true
      debugPrint('Emergency sound will play via system notification');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _vibrateDevice() async {
    try {
      // Use Flutter's built-in haptic feedback - works reliably across all devices
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 300));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 300));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error with haptic feedback: $e');
    }
  }

  Future<void> showInAppAlert(BuildContext context, ResQMessage message) async {
    // Play sound and vibrate
    await _playEmergencySound();
    await _vibrateDevice();

    if (!context.mounted) return;

    // Show popup dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.red, width: 3),
        ),
        title: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.white, size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🆘 EMERGENCY ALERT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    message.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildAlertRow(Icons.access_time, message.getFormattedTime()),
            const SizedBox(height: 8),
            _buildAlertRow(Icons.location_on, message.getCoordinatesString()),
            const SizedBox(height: 8),
            _buildAlertRow(Icons.router, '${message.hopCount} hops'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to message list
              Navigator.pushNamed(context, '/messages');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.list, color: Colors.white),
            label: const Text(
              'View All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
