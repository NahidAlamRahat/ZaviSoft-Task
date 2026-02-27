import 'package:flutter/material.dart';

/// A delegate for pinned SliverPersistentHeader that wraps a TabBar.
class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) => false;
}
