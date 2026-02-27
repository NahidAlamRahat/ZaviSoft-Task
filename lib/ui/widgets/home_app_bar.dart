import 'package:flutter/material.dart';
import '../../models/models.dart';

/// The collapsible SliverAppBar with banner image and user profile.
class HomeAppBar extends StatelessWidget {
  final User? userProfile;
  final VoidCallback onLogout;

  const HomeAppBar({
    super.key,
    required this.userProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('FakeStore', style: TextStyle(color: Colors.white)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network('https://picsum.photos/800/400', fit: BoxFit.cover),
            Container(color: Colors.black.withValues(alpha: 0.4)),
            if (userProfile != null)
              Positioned(
                bottom: 48,
                left: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(userProfile!.username[0].toUpperCase()),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hi, ${userProfile!.name['firstname']}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
      ],
    );
  }
}
