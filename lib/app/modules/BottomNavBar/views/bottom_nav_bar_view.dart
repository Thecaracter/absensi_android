import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_bar_controller.dart';
import '../../home/views/home_view.dart';
import '../../attendance/views/attendance_view.dart';
import '../../leave_request/views/leave_request_view.dart';
import '../../profile/views/profile_view.dart';
import '../../../controller/theme_controller.dart';
import '../../../utils/color_constant.dart';

class BottomNavBarView extends GetView<BottomNavBarController> {
  const BottomNavBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              // Main content
              IndexedStack(
                index: controller.currentIndex.value,
                children: const [
                  HomeView(),
                  AttendanceView(),
                  LeaveRequestView(),
                  ProfileView(),
                ],
              ),

              // Floating theme toggle button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 20,
                child: _buildFloatingThemeToggle(themeController),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: themeController.isDarkMode.value
                      ? Colors.black.withOpacity(0.3)
                      : AppColors.slate400.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: themeController.isDarkMode.value
                      ? AppColors.slate800.withOpacity(0.95)
                      : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: themeController.isDarkMode.value
                        ? AppColors.slate700.withOpacity(0.5)
                        : AppColors.slate200.withOpacity(0.8),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      controller: controller,
                      themeController: themeController,
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.access_time_outlined,
                      activeIcon: Icons.access_time_rounded,
                      label: 'Presensi',
                      controller: controller,
                      themeController: themeController,
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.event_note_outlined,
                      activeIcon: Icons.event_note_rounded,
                      label: 'Cuti',
                      controller: controller,
                      themeController: themeController,
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profil',
                      controller: controller,
                      themeController: themeController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildFloatingThemeToggle(ThemeController themeController) {
    return GestureDetector(
      onTap: themeController.toggleTheme,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          gradient: themeController.isDarkMode.value
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.amber500, AppColors.yellow500],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.slate700, AppColors.slate900],
                ),
          borderRadius: BorderRadius.circular(22.5),
          boxShadow: [
            BoxShadow(
              color: themeController.isDarkMode.value
                  ? AppColors.amber500.withOpacity(0.4)
                  : AppColors.slate700.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: child,
            );
          },
          child: Icon(
            themeController.isDarkMode.value
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            key: ValueKey(themeController.isDarkMode.value),
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required BottomNavBarController controller,
    required ThemeController themeController,
  }) {
    final isSelected = controller.currentIndex.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container dengan smooth animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                width: isSelected ? 55 : 45,
                height: 35,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? (themeController.isDarkMode.value
                          ? const LinearGradient(
                              colors: [AppColors.amber500, AppColors.yellow500],
                            )
                          : const LinearGradient(
                              colors: [AppColors.amber600, AppColors.yellow600],
                            ))
                      : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: themeController.isDarkMode.value
                                ? AppColors.amber500.withOpacity(0.4)
                                : AppColors.amber600.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey('${index}_$isSelected'),
                      size: isSelected ? 24 : 22,
                      color: isSelected
                          ? Colors.white
                          : (themeController.isDarkMode.value
                              ? AppColors.slate400
                              : AppColors.slate600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Label dengan smooth transition
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (themeController.isDarkMode.value
                          ? AppColors.amber500
                          : AppColors.amber600)
                      : (themeController.isDarkMode.value
                          ? AppColors.slate400
                          : AppColors.slate600),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
