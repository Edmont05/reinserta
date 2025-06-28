import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_main_bar.dart';

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
      appBar: const AppMainBar(), // <- Use your custom AppBar here
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
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
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(
                        item['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['description']!),
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
          // Action when pressing the add button
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}