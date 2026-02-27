import 'package:flutter/material.dart';
import 'sliver_tab_bar_delegate.dart';

/// A sticky category tab bar wrapped in a SliverPersistentHeader.
class CategoryTabBar extends StatelessWidget {
  final TabController? tabController;
  final List<String> categories;
  final ValueChanged<int> onTap;

  const CategoryTabBar({
    super.key,
    required this.tabController,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverTabBarDelegate(
        TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          onTap: onTap,
          tabs: categories.map((cat) => Tab(text: cat.toUpperCase())).toList(),
        ),
      ),
    );
  }
}
