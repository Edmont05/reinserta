import 'package:flutter/material.dart';
import 'package:reinserta/services/firebase_services.dart';
import '../../../theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeHistorySection extends StatelessWidget {
  final String empleadoId;
  final Future<void> Function(List<Map<String, dynamic>>) onPrint;
  const EmployeeHistorySection({
    super.key,
    required this.empleadoId,
    required this.onPrint,
  });

  // Consulta los datos del usuario en Firestore
  Future<Map<String, dynamic>?> getEmpleadoData(String empleadoId) async {
    final doc = await FirebaseFirestore.instance.collection('Users').doc(empleadoId).get();
    return doc.data();
  }

  String rangoNombre(int rango) {
    switch (rango) {
      case 1:
        return 'Plata';
      case 2:
        return 'Oro';
      case 3:
        return 'Platino';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getEmpleadoData(empleadoId),
      builder: (context, snapshotUser) {
        double puntaje = 0;
        int rango = 1;
        if (snapshotUser.hasData && snapshotUser.data != null) {
          puntaje = (snapshotUser.data!['calificacion'] ?? 0).toDouble();
          rango = (snapshotUser.data!['rango'] ?? 1);
        }

        // Puedes ajustar estos colores según el rango si lo deseas
        Color rangoColor;
        switch (rango) {
          case 1:
            rangoColor = Colors.grey;
            break;
          case 2:
            rangoColor = Colors.amber;
            break;
          case 3:
            rangoColor = Colors.blue;
            break;
          default:
            rangoColor = AppColors.primary;
        }

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
                      color: rangoColor,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rangoNombre(rango),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: rangoColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Puntaje: ${puntaje.toStringAsFixed(2)} / 5.0',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
                            value: puntaje / 5.0,
                            backgroundColor: AppColors.progressBg,
                            valueColor: AlwaysStoppedAnimation<Color>(rangoColor),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        puntaje.toStringAsFixed(2),
                        style: TextStyle(
                          color: rangoColor,
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
      },
    );
  }
}