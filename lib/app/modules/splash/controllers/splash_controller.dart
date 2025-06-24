import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> logoScaleAnimation;
  late Animation<double> logoOpacityAnimation;
  late Animation<double> textFadeAnimation;
  late Animation<Offset> textSlideAnimation;

  final isLoading = true.obs;
  final loadingProgress = 0.0.obs;
  final statusMessage = 'Memuat aplikasi...'.obs;
  final showLogo = false.obs;
  final showText = false.obs;

  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 1500);

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticOut,
    ));

    logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
    ));
  }

  Future<void> _startSplashSequence() async {
    try {
      showLogo.value = true;
      animationController.forward();

      await _updateProgress(0.2, 'Memeriksa koneksi...');
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateProgress(0.4, 'Memuat konfigurasi...');
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateProgress(0.6, 'Memeriksa autentikasi...');
      await Future.delayed(const Duration(milliseconds: 500));

      bool isAuthenticated = await _checkAuthenticationStatus();

      await _updateProgress(0.8, 'Menyelesaikan...');
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateProgress(1.0, 'Selesai!');
      await Future.delayed(const Duration(milliseconds: 500));

      _navigateToNextScreen(isAuthenticated);
    } catch (e) {
      print('Splash error: $e');
      statusMessage.value = 'Terjadi kesalahan, melanjutkan...';
      await Future.delayed(const Duration(seconds: 1));
      _navigateToNextScreen(false);
    }
  }

  Future<void> _updateProgress(double progress, String message) async {
    loadingProgress.value = progress;
    statusMessage.value = message;

    if (progress > 0.2 && !showText.value) {
      showText.value = true;
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      print('Auth check error: $e');
      return false;
    }
  }

  void _navigateToNextScreen(bool isAuthenticated) {
    isLoading.value = false;

    if (isAuthenticated) {
      Get.offAllNamed('/bottom-nav-bar');
    } else {
      Get.offAllNamed('/login');
    }
  }

  void goToLogin() {
    Get.offAllNamed('/login');
  }

  void goToHome() {
    Get.offAllNamed('/bottom-nav-bar');
  }

  void skipSplash() {
    animationController.stop();
    _navigateToNextScreen(false);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
