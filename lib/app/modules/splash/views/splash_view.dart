// lib/app/modules/splash/views/splash_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sistem_presensi/app/controller/theme_controller.dart';
import 'package:sistem_presensi/app/utils/color_constant.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => Scaffold(
          backgroundColor: themeController.isDarkMode.value
              ? AppColors.background
              : AppColors.backgroundLightMode,
          body: Container(
            decoration: BoxDecoration(
              gradient: themeController.isDarkMode.value
                  ? AppColors.backgroundGradient
                  : AppColors.backgroundGradientLight,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Main content area
                  Expanded(
                    flex: 3,
                    child: _buildMainContent(themeController),
                  ),

                  // Loading area
                  Expanded(
                    flex: 1,
                    child: _buildLoadingArea(themeController),
                  ),

                  // Footer area
                  _buildFooter(themeController),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildMainContent(ThemeController themeController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo with animation
          Obx(() => controller.showLogo.value
              ? AnimatedBuilder(
                  animation: controller.animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: controller.logoScaleAnimation.value,
                      child: Opacity(
                        opacity: controller.logoOpacityAnimation.value,
                        child: _buildLogo(themeController),
                      ),
                    );
                  },
                )
              : const SizedBox()),

          const SizedBox(height: 40),

          // App title with animation
          Obx(() => controller.showText.value
              ? SlideTransition(
                  position: controller.textSlideAnimation,
                  child: FadeTransition(
                    opacity: controller.textFadeAnimation,
                    child: _buildAppTitle(themeController),
                  ),
                )
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildLogo(ThemeController themeController) {
    return Hero(
      tag: 'app_logo',
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          gradient: themeController.isDarkMode.value
              ? AppColors.primaryGradient
              : AppColors.primaryGradientLight,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: themeController.isDarkMode.value
                  ? AppColors.amber500.withOpacity(0.4)
                  : AppColors.amber600.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: themeController.isDarkMode.value
                  ? AppColors.amber500.withOpacity(0.2)
                  : AppColors.amber600.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.fingerprint,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAppTitle(ThemeController themeController) {
    return Column(
      children: [
        Text(
          'Sistem Presensi',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: themeController.isDarkMode.value
                ? AppColors.textPrimary
                : AppColors.textPrimaryLight,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aplikasi Absensi Digital',
          style: TextStyle(
            fontSize: 16,
            color: themeController.isDarkMode.value
                ? AppColors.textSecondary
                : AppColors.textSecondaryLight,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingArea(ThemeController themeController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Progress indicator
        Obx(() => Container(
              width: 200,
              height: 6,
              decoration: BoxDecoration(
                color: themeController.isDarkMode.value
                    ? AppColors.slate700
                    : AppColors.slate300,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 200 * controller.loadingProgress.value,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: themeController.isDarkMode.value
                          ? AppColors.primaryGradient
                          : AppColors.primaryGradientLight,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),

        const SizedBox(height: 20),

        // Status message
        Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                controller.statusMessage.value,
                key: ValueKey(controller.statusMessage.value),
                style: TextStyle(
                  fontSize: 14,
                  color: themeController.isDarkMode.value
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),

        const SizedBox(height: 20),

        // Loading spinner
        Obx(() => controller.isLoading.value
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              )
            : const SizedBox()),
      ],
    );
  }

  Widget _buildFooter(ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Version info
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: themeController.isDarkMode.value
                  ? AppColors.textMuted
                  : AppColors.textMutedLight,
            ),
          ),

          const SizedBox(height: 8),

          // Company info
          Text(
            '© 2024 Sistem Presensi',
            style: TextStyle(
              fontSize: 12,
              color: themeController.isDarkMode.value
                  ? AppColors.textMuted
                  : AppColors.textMutedLight,
            ),
          ),

          // Development mode skip button
          if (Get.arguments?['dev_mode'] == true) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: controller.skipSplash,
              child: Text(
                'Skip Splash (Dev)',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
