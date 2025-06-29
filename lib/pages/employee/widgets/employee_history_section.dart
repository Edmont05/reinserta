import 'package:flutter/material.dart';
import 'package:reinserta/services/firebase_services.dart';
import '../../../theme/app_colors.dart';

class EmployeeHistorySection extends StatelessWidget {
  final Future<void> Function(List<Map<String, dynamic>>) onPrint;
  const EmployeeHistorySection({super.key, required this.onPrint});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card de confiabilidad
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.reliableBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.reliableIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.verified,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Confiable',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.4,
                        backgroundColor: AppColors.progressBg,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '4/10',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              'Trabajos anteriores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Imprimir extracto',
              onPressed: () async {
                final snapshot = await getHistorialRealtime().first;
                await onPrint(snapshot.cast<Map<String, dynamic>>());
              },
            )
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List>(
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
            return Column(
              children: [
                ...historial.map((item) {
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
                          if (item['entrada'] != null && item['salida'] != null)
                            Builder(
                              builder: (context) {
                                DateTime entradaDate;
                                DateTime salidaDate;

                                if (item['entrada'] is Map && item['entrada'].containsKey('_seconds')) {
                                  entradaDate = DateTime.fromMillisecondsSinceEpoch(item['entrada']['_seconds'] * 1000);
                                } else {
                                  entradaDate = DateTime.tryParse(item['entrada'].toString()) ?? DateTime.now();
                                }

                                if (item['salida'] is Map && item['salida'].containsKey('_seconds')) {
                                  salidaDate = DateTime.fromMillisecondsSinceEpoch(item['salida']['_seconds'] * 1000);
                                } else {
                                  salidaDate = DateTime.tryParse(item['salida'].toString()) ?? DateTime.now();
                                }

                                String twoDigits(int n) => n.toString().padLeft(2, '0');
                                String fechaHora(DateTime dt) =>
                                    "${twoDigits(dt.day)}/${twoDigits(dt.month)}/${dt.year} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}";

                                return Text(
                                  "Entrada: ${fechaHora(entradaDate)}\nSalida: ${fechaHora(salidaDate)}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ],
    );
  }
}