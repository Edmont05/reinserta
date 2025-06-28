import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'request_step1_page.dart';

class EmployerHistoryPage extends StatelessWidget {
  const EmployerHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> history = [
      {'title': 'Solicitud 1', 'description': 'Descripción de la solicitud 1.'},
      {'title': 'Solicitud 2', 'description': 'Descripción de la solicitud 2.'},
      {'title': 'Solicitud 3', 'description': 'Descripción de la solicitud 3.'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Reinserta',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historial',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      title: Text(
                        item['title']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        item['description']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RequestStep1Page()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}