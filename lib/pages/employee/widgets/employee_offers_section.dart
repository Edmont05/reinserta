import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reinserta/services/firebase_services.dart';
import '../../../theme/app_colors.dart';

class EmployeeOffersSection extends StatelessWidget {
  final String empleadoId;
  const EmployeeOffersSection({super.key, required this.empleadoId});

  String formatFecha(dynamic fecha) {
    DateTime? dt;
    if (fecha == null) return 'Sin fecha';
    if (fecha is DateTime) dt = fecha;
    else if (fecha is Timestamp) dt = fecha.toDate();
    else if (fecha is String) dt = DateTime.tryParse(fecha);
    else if (fecha is Map && fecha.containsKey('_seconds')) {
      dt = DateTime.fromMillisecondsSinceEpoch(fecha['_seconds'] * 1000);
    }
    if (dt == null) return 'Sin fecha';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(dt.day)}/${twoDigits(dt.month)}/${dt.year} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Ofertas vigentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: getSolicitudesByEmpleadoRealtime(empleadoId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No hay ofertas vigentes');
            }
            final filteredSolicitudes = snapshot.data!;

            return Column(
              children: [
                ...filteredSolicitudes.map((item) {
                  final monto = item['monto'];
                  final entrada = item['entrada'];
                  final salida = item['salida'];
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
                        children: [
                          Expanded(
                            child: Text(
                              item['profesion'] ?? 'Sin profesion',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (monto != null)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Text(
                                'Bs. $monto',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          if (item['estado'] == 'pendiente') ...[
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              tooltip: 'Rechazar',
                              onPressed: () async {
                                await eliminarCandidatoPorEmpleadoYSolicitud(empleadoId, item['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Solicitud cancelada')),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              tooltip: 'Aceptar',
                              onPressed: () async {
                                await aceptarSolicitudEmpleado(
                                  empleadoId: empleadoId,
                                  solicitudId: item['id'],
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Solicitud aceptada y procesada')),
                                );
                              },
                            ),
                          ] else if (item['estado'] == 'en progreso') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'En progreso',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['descripcion'] ?? 'Sin descripción',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.login, size: 14, color: Colors.grey),
                              const SizedBox(width: 3),
                              Text(
                                "Entrada: ${formatFecha(entrada)}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),

                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.logout, size: 14, color: Colors.grey),
                              const SizedBox(width: 3),
                              Text(
                                "Salida: ${formatFecha(salida)}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
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
        const SizedBox(height: 80),
      ],
    );
  }
}