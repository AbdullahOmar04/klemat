import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:klemat/themes/app_localization.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('leaderboard')),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('users')
                .orderBy('points', descending: true)
                .limit(50)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading leaderboard'));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No players yet!'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final name = data['username'] ?? 'Unknown';
              final points = data['points'] ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: Text('${index + 1}'),
                ),
                title: Text(name),
                trailing: Text(
                  '$points ${AppLocalizations.of(context).translate('pts')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
