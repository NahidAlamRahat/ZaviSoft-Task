import 'package:flutter/material.dart';

class ScrollGestureViewModel extends ChangeNotifier {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Track the current active tab index
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // Expose the animation for the UI to bind to Transform translate
  Animation<double> get slideAnimation => _slideAnimation;

  // Threshold to determine if a swipe was successful
  final double swipeThresholdX = 100.0;

  // To lock dragging to horizontal only (avoid diagonal jitter)
  bool _isDragging = false;
  double _dragDistance = 0.0;

  void init(TickerProvider vsync, int tabCount) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  void onHorizontalDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragDistance = 0.0;
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    // Calculate raw translation
    _dragDistance += details.primaryDelta ?? 0.0;

    notifyListeners();
  }

  void onHorizontalDragEnd(DragEndDetails details, int totalTabs) {
    if (!_isDragging) return;
    _isDragging = false;

    // Check if swipe distance crossed the threshold
    if (_dragDistance < -swipeThresholdX && _currentIndex < totalTabs - 1) {
      // Swiped Left -> Go to Next Tab
      _animateToTab(_currentIndex + 1);
    } else if (_dragDistance > swipeThresholdX && _currentIndex > 0) {
      // Swiped Right -> Go to Prev Tab
      _animateToTab(_currentIndex - 1);
    } else {
      // Snap back to current tab (cancel swipe)
      _snapBack();
    }
  }

  void onTapTab(int index) {
    if (index == _currentIndex) return;
    _animateToTab(index);
  }

  void _animateToTab(int newIndex) {
    double startValue = _currentIndex.toDouble();
    if (_dragDistance != 0) {}

    _slideAnimation =
        Tween<double>(
          begin: _currentIndex.toDouble(),
          end: newIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward(from: 0.0).then((_) {
      _currentIndex = newIndex;
      _dragDistance = 0.0;
      notifyListeners();
    });

    // Notify immediately to start rendering the animation
    notifyListeners();
  }

  void _snapBack() {
    _slideAnimation =
        Tween<double>(
          begin:
              _currentIndex.toDouble() -
              (_dragDistance > 0 ? 0.2 : -0.2), // approximate
          end: _currentIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward(from: 0.0).then((_) {
      _dragDistance = 0.0;
      notifyListeners();
    });

    notifyListeners();
  }

  // Helper for UI to get the current translation offset
  double getTranslationMultiplier() {
    if (_isDragging) {
      // Return a raw pixel value (needs screen width context, so UI handles drag distance directly)
      // We return a special flag or just handle it in UI logic
      return -999.0;
    }
    return _slideAnimation.value;
  }

  double get dragDistance => _dragDistance;
  bool get isDragging => _isDragging;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
