import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/gesture_viewmodel.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/product_card.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  late ScrollGestureViewModel _gestureVM;

  @override
  void initState() {
    super.initState();
    _gestureVM = Provider.of<ScrollGestureViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = Provider.of<HomeViewModel>(context, listen: false);
      homeVM.fetchProducts().then((_) {
        _gestureVM.init(this, homeVM.categories.length);

        setState(() {
          _tabController = TabController(
            length: homeVM.categories.length,
            vsync: this,
          );

          _gestureVM.addListener(() {
            if (_tabController!.index != _gestureVM.currentIndex) {
              _tabController!.animateTo(_gestureVM.currentIndex);
            }
          });

          _tabController!.addListener(() {
            if (!_tabController!.indexIsChanging) {
              _gestureVM.onTapTab(_tabController!.index);
            }
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final homeVM = Provider.of<HomeViewModel>(context);
    final gestureVM = Provider.of<ScrollGestureViewModel>(context);

    if (homeVM.isLoading ||
        homeVM.categories.isEmpty ||
        _tabController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeCategory = homeVM.categories[gestureVM.currentIndex];
    final products = homeVM.getProductsByCategory(activeCategory);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await homeVM.fetchProducts();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Collapsible Header
            HomeAppBar(
              userProfile: authVM.userProfile,
              onLogout: () {
                authVM.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),

            // Sticky Tab Bar
            CategoryTabBar(
              tabController: _tabController,
              categories: homeVM.categories,
              onTap: (index) => gestureVM.onTapTab(index),
            ),

            // Product Grid
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= products.length) return null;

                  return ProductCard(
                    product: products[index],
                    onHorizontalDragStart: gestureVM.onHorizontalDragStart,
                    onHorizontalDragUpdate: gestureVM.onHorizontalDragUpdate,
                    onHorizontalDragEnd: (details) => gestureVM
                        .onHorizontalDragEnd(details, homeVM.categories.length),
                  );
                }, childCount: products.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
