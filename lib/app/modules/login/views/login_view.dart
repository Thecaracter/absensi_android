import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sistem_presensi/app/controller/theme_controller.dart';
import 'package:sistem_presensi/app/modules/login/controllers/login_controller.dart';

import 'package:sistem_presensi/app/utils/color_constant.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    final themeController = Get.put(ThemeController());

    return Obx(() => Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: themeController.isDarkMode.value
                  ? AppColors.backgroundGradient
                  : AppColors.backgroundGradientLight,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Theme Toggle Button
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: themeController.toggleTheme,
                          icon: Icon(
                            themeController.isDarkMode.value
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: themeController.isDarkMode.value
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),

                      // Logo/Header with modern design
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: themeController.isDarkMode.value
                              ? AppColors.primaryGradient
                              : AppColors.primaryGradientLight,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: themeController.isDarkMode.value
                                  ? AppColors.amber500.withOpacity(0.3)
                                  : AppColors.amber600.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title with modern typography
                      Text(
                        'Login Karyawan',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: themeController.isDarkMode.value
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk ke sistem presensi perusahaan',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeController.isDarkMode.value
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Form Container with glassmorphism effect
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: themeController.isDarkMode.value
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: themeController.isDarkMode.value
                                ? Colors.white.withOpacity(0.1)
                                : AppColors.borderLight.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeController.isDarkMode.value
                                  ? AppColors.cardShadow
                                  : AppColors.cardShadowLight,
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Email Field
                            TextField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                color: themeController.isDarkMode.value
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryLight,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: themeController.isDarkMode.value
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: themeController.isDarkMode.value
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: themeController.isDarkMode.value
                                        ? AppColors.border
                                        : AppColors.borderLight,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: themeController.isDarkMode.value
                                        ? AppColors.border
                                        : AppColors.borderLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: themeController.isDarkMode.value
                                        ? AppColors.borderFocus
                                        : AppColors.borderFocusLight,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: themeController.isDarkMode.value
                                    ? AppColors.surface.withOpacity(0.5)
                                    : AppColors.slate100.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            Obx(() => TextField(
                                  controller: controller.passwordController,
                                  obscureText:
                                      controller.isPasswordHidden.value,
                                  style: TextStyle(
                                    color: themeController.isDarkMode.value
                                        ? AppColors.textPrimary
                                        : AppColors.textPrimaryLight,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      color: themeController.isDarkMode.value
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryLight,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: themeController.isDarkMode.value
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryLight,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordHidden.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: themeController.isDarkMode.value
                                            ? AppColors.textSecondary
                                            : AppColors.textSecondaryLight,
                                      ),
                                      onPressed:
                                          controller.togglePasswordVisibility,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: themeController.isDarkMode.value
                                            ? AppColors.border
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: themeController.isDarkMode.value
                                            ? AppColors.border
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: themeController.isDarkMode.value
                                            ? AppColors.borderFocus
                                            : AppColors.borderFocusLight,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: themeController.isDarkMode.value
                                        ? AppColors.surface.withOpacity(0.5)
                                        : AppColors.slate100.withOpacity(0.5),
                                  ),
                                )),
                            const SizedBox(height: 24),

                            // Login Button with gradient
                            Obx(() => SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : controller.login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.zero,
                                      elevation: 0,
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: controller.isLoading.value
                                            ? (themeController.isDarkMode.value
                                                ? AppColors.disabledGradient
                                                : AppColors
                                                    .disabledGradientLight)
                                            : (themeController.isDarkMode.value
                                                ? AppColors.primaryGradient
                                                : AppColors
                                                    .primaryGradientLight),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: controller.isLoading.value
                                            ? null
                                            : [
                                                BoxShadow(
                                                  color: themeController
                                                          .isDarkMode.value
                                                      ? AppColors.buttonShadow
                                                      : AppColors
                                                          .buttonShadowLight,
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: controller.isLoading.value
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text(
                                                'Masuk',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Forgot Password with modern styling

                      const SizedBox(height: 32),

                      // Footer text
                      Text(
                        '© 2025 Sistem Presensi',
                        style: TextStyle(
                          color: themeController.isDarkMode.value
                              ? AppColors.textMuted
                              : AppColors.textMutedLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
