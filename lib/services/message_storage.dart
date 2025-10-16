import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/resq_message.dart';

/// MessageStorage - Handles local storage of messages and user profile
/// Uses SharedPreferences for lightweight data persistence
class MessageStorage {
  static const String _messagesKey = 'resq_messages';
  static const String _userNameKey = 'user_name';
  static const String _defaultUserName = 'Emergency User';

  /// Get user's name from storage
  Future<String> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey) ?? _defaultUserName;
    } catch (e) {
      return _defaultUserName;
    }
  }

  /// Set user's name in storage
  Future<bool> setUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userNameKey, name);
    } catch (e) {
      return false;
    }
  }

  /// Save a new message to storage
  Future<bool> saveMessage(ResQMessage message) async {
    try {
      final messages = await getMessages();

      // Check if message already exists
      if (messages.any((m) => m.id == message.id)) {
        return true; // Already saved
      }

      // Add new message
      messages.add(message);

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      final jsonList = messages.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      return await prefs.setString(_messagesKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Get all messages from storage
  Future<List<ResQMessage>> getMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_messagesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ResQMessage.fromJson(json)).toList()..sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      ); // Most recent first
    } catch (e) {
      return [];
    }
  }

  /// Clear all messages from storage
  Future<bool> clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_messagesKey);
    } catch (e) {
      return false;
    }
  }

  /// Get message by ID
  Future<ResQMessage?> getMessageById(String id) async {
    try {
      final messages = await getMessages();
      return messages.firstWhere(
        (m) => m.id == id,
        orElse: () => throw Exception('Message not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get message count
  Future<int> getMessageCount() async {
    final messages = await getMessages();
    return messages.length;
  }

  /// Delete a specific message
  Future<bool> deleteMessage(String id) async {
    try {
      final messages = await getMessages();
      messages.removeWhere((m) => m.id == id);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = messages.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      return await prefs.setString(_messagesKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Check if message exists
  Future<bool> messageExists(String id) async {
    final messages = await getMessages();
    return messages.any((m) => m.id == id);
  }
}
