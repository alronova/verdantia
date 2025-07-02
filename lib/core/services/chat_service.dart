import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

final String backendUrl = "https://plant-chat-backend.vercel.app/";

class ChatUtils {
  static final _dio = Dio();

  static Future<void> sendMessage(String text) async {
    final user = FirebaseAuth.instance.currentUser!;
    final firestore = FirebaseFirestore.instance;
    final uid = user.uid;

    if (text.trim().isEmpty) return;

    // Save user message to Firestore
    await firestore.collection('chats').doc(uid).collection('messages').add({
      'role': 'user',
      'content': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    try {
      // Send message to AI backend
      final response = await _dio.post(
        '${backendUrl}chat',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'messages': [
            {'role': 'user', 'content': text.trim()}
          ]
        },
      );

      final reply = response.data['reply'];

      // Save AI reply to Firestore
      await firestore.collection('chats').doc(uid).collection('messages').add({
        'role': 'assistant',
        'content': reply,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Dio error: $e');

      await firestore.collection('chats').doc(uid).collection('messages').add({
        'role': 'assistant',
        'content':
            'Sorry, I couldn\'t respond right now. Please try again later!',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
