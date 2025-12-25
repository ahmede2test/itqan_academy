import 'package:flutter/material.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/features/home/presentation/views/services/gpa_page.dart';
import 'package:itqan_academy/features/home/presentation/views/services/todo_page.dart';
import 'package:itqan_academy/features/home/presentation/views/services/notes_page.dart';
import 'package:itqan_academy/features/home/presentation/views/services/pomodoro_page.dart';

class DeliveryPage extends StatelessWidget {
  const DeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).ServicesPage,
          style:
              const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added ScrollView for safety
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("الأدوات الحسابية"),
              const SizedBox(height: 15),

              // حاسبة المعدل (GPA)
              _buildToolCard(
                context,
                title: "حاسبة GPA",
                icon: Icons.calculate_rounded,
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GPAPage()));
                },
              ),

              const SizedBox(height: 30),

              _buildSectionHeader("التنظيم والمذاكرة"),
              const SizedBox(height: 15),

              // قائمة الأدوات التنظيمية
              _buildListTool(
                title: "ملاحظات المحاضرات",
                subtitle: "دوّن أهم النقاط أثناء المذاكرة",
                icon: Icons.edit_note_rounded,
                trailingColor: Colors.greenAccent,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotesPage())),
              ),
              _buildListTool(
                title: "قائمة المهام (To-Do)",
                subtitle: "نظم جدولك الدراسي اليومي",
                icon: Icons.checklist_rtl_rounded,
                trailingColor: Colors.purpleAccent,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ToDoPage())),
              ),
              _buildListTool(
                title: "مؤقت المذاكرة (Pomodoro)",
                subtitle: "ركز لمده 25 دقيقة بدون تشتت",
                icon: Icons.timer_outlined,
                trailingColor: Colors.redAccent,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PomodoroPage())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
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
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Center(
              // Center the text since it might be wide now
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // قائمة الأدوات الطولية
  Widget _buildListTool(
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color trailingColor,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(icon, color: Colors.white70, size: 30),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo')),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: Colors.grey, fontSize: 12, fontFamily: 'Cairo')),
        trailing: Icon(Icons.arrow_forward_ios, color: trailingColor, size: 16),
        onTap: onTap,
      ),
    );
  }
}
