import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/features/home/presentation/views/services/gpa_page.dart';
import 'package:itqan_academy/features/home/presentation/views/services/todo_page.dart';
import 'package:itqan_academy/features/home/presentation/views/services/notes_page.dart';
import 'package:itqan_academy/features/home/presentation/views/services/pomodoro_page.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';
import 'package:itqan_academy/features/home/presentation/manger/services_cubit/services_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/services_cubit/services_state.dart';
import 'package:itqan_academy/core/utils/functions/is_arabic.dart';
import 'package:itqan_academy/core/utils/functions/custom_toast.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServicesCubit>().fetchAcademyServices();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = isArabic();

    return BlocListener<ServicesCubit, ServicesState>(
      listener: (context, state) {
        if (state is ServiceOrderSuccess) {
          customShowToast(msg: state.message);
        } else if (state is ServicesError) {
          customShowToast(msg: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).ServicesPage,
            style: const TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(isAr ? "الأدوات الدراسية" : "Study Tools"),
                const SizedBox(height: 15),

                // Grid for Tools
                LayoutBuilder(builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildToolCard(
                        context,
                        title: isAr ? "حاسبة GPA" : "GPA Calculator",
                        icon: Icons.calculate_rounded,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const GPAPage())),
                      ),
                      _buildToolCard(
                        context,
                        title: isAr ? "الملاحظات" : "Notes",
                        icon: Icons.edit_note_rounded,
                        color: Colors.greenAccent,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotesPage())),
                      ),
                      _buildToolCard(
                        context,
                        title: isAr ? "المهام" : "Tasks",
                        icon: Icons.checklist_rtl_rounded,
                        color: Colors.purpleAccent,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ToDoPage())),
                      ),
                      _buildToolCard(
                        context,
                        title: isAr ? "بومودورو" : "Pomodoro",
                        icon: Icons.timer_outlined,
                        color: Colors.redAccent,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PomodoroPage())),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 30),

                _buildSectionHeader(
                    isAr ? "خدمات الأكاديمية" : "Academy Services"),
                const SizedBox(height: 15),

                // Real Academy Services
                BlocBuilder<ServicesCubit, ServicesState>(
                  builder: (context, state) {
                    if (state is ServicesLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary));
                    }

                    if (state is ServicesLoaded) {
                      if (state.services.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Icon(Icons.info_outline_rounded,
                                  color: Colors.grey[400], size: 40),
                              const SizedBox(height: 10),
                              Text(
                                isAr
                                    ? "لا توجد خدمات متاحة حالياً"
                                    : "No services available right now",
                                style: const TextStyle(
                                    fontFamily: 'Cairo', color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.services.length,
                        itemBuilder: (context, index) {
                          final service = state.services[index];
                          return _buildServiceListItem(
                            context,
                            title: isAr ? service.titleAr : service.titleEn,
                            subtitle: isAr
                                ? service.descriptionAr
                                : service.descriptionEn,
                            icon: _getIconData(service.icon),
                            price: service.price,
                            onOrder: () => context
                                .read<ServicesCubit>()
                                .orderAcademyService(service.id),
                            isAr: isAr,
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'support':
        return Icons.support_agent_rounded;
      case 'certificate':
        return Icons.card_membership_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _buildToolCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    String? price,
    required VoidCallback onOrder,
    required bool isAr,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo'),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 12, fontFamily: 'Cairo'),
            ),
            if (price != null) ...[
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ],
          ],
        ),
        trailing: SizedBox(
          width: 80, // 📏 Constrain width to prevent ListTile assertion error
          child: ElevatedButton(
            onPressed: onOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            ),
            child: Text(
              isAr ? "طلب" : "Order",
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}
