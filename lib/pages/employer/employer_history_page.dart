import 'package:flutter/material.dart';
import 'package:reinserta/services/firebase_services.dart';
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
              child: StreamBuilder<List>(
                stream: getHistorialRealtime(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay historial');
                  }

                  final historial = snapshot.data!.cast<Map<String, dynamic>>();
                  return ListView.builder(
                    itemCount: historial.length,
                    itemBuilder: (context, index) {
                      final item = historial[index];
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
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
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['profesion'] ?? 'Sin profesión',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (item['monto'] != null)
                                Text(
                                  "Bs. ${item['monto']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item['entrada'] != null &&
                                  item['salida'] != null)
                                Builder(
                                  builder: (context) {
                                    DateTime entradaDate;
                                    DateTime salidaDate;

                                    if (item['entrada'] is Map &&
                                        item['entrada'].containsKey(
                                          '_seconds',
                                        )) {
                                      entradaDate =
                                          DateTime.fromMillisecondsSinceEpoch(
                                            item['entrada']['_seconds'] * 1000,
                                          );
                                    } else {
                                      entradaDate =
                                          DateTime.tryParse(
                                            item['entrada'].toString(),
                                          ) ??
                                          DateTime.now();
                                    }

                                    if (item['salida'] is Map &&
                                        item['salida'].containsKey(
                                          '_seconds',
                                        )) {
                                      salidaDate =
                                          DateTime.fromMillisecondsSinceEpoch(
                                            item['salida']['_seconds'] * 1000,
                                          );
                                    } else {
                                      salidaDate =
                                          DateTime.tryParse(
                                            item['salida'].toString(),
                                          ) ??
                                          DateTime.now();
                                    }

                                    String twoDigits(int n) =>
                                        n.toString().padLeft(2, '0');
                                    String fechaHora(DateTime dt) =>
                                        "${twoDigits(dt.day)}/${twoDigits(dt.month)}/${dt.year} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}";

                                    return Text(
                                      "Entrada: ${fechaHora(entradaDate)}\nSalida: ${fechaHora(salidaDate)}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.8),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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
