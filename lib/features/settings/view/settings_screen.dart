import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;
  bool autoBackup = true;

  String? username;
  String? email;

  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    if (userId == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    setState(() {
      username = doc.data()?['username'];
      email = doc.data()?['email'] ?? FirebaseAuth.instance.currentUser?.email;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      context.go('/');
    } catch (e) {
      debugPrint('Logout failed: $e');
    }
  }

  void _editUsernameDialog() {
    final TextEditingController _controller =
        TextEditingController(text: username ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Username"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "Enter username"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUsername = _controller.text.trim();
              if (newUsername.isNotEmpty && userId != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({'username': newUsername});
                setState(() => username = newUsername);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = username ?? email ?? 'Hi';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Username display with edit icon
              Row(
                children: [
                  const Icon(Icons.account_circle, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: "Edit Username",
                    onPressed: _editUsernameDialog,
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Settings toggles
              Expanded(
                child: ListView(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      value: notificationsEnabled,
                      onChanged: (val) {
                        setState(() => notificationsEnabled = val);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Auto Backup'),
                      value: autoBackup,
                      onChanged: (val) {
                        setState(() => autoBackup = val);
                      },
                    ),
                  ],
                ),
              ),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
