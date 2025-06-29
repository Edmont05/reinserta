import 'package:flutter/material.dart';
import 'package:reinserta/services/firebase_services.dart';
import '../../../theme/app_colors.dart';

class EmployeeOffersSection extends StatelessWidget {
  final String empleadoId;
  const EmployeeOffersSection({super.key, required this.empleadoId});

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
                      subtitle: Text(
                        item['descripcion'] ?? 'Sin descripción',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
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