import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reinserta/services/firebase_services.dart';
import '../../theme/app_colors.dart';
import 'request_step1_page.dart';

const String empleadorId = '1JSngNx7QxeeEBC6lPWW'; // ← tu ID de prueba

class EmployerHistoryPage extends StatelessWidget {
  const EmployerHistoryPage({super.key});

  /// --- Utils --------------------------------------------------------------

  String _formatFecha(dynamic fecha) {
    DateTime? dt;
    if (fecha == null) return 'Sin fecha';
    if (fecha is DateTime) {
      dt = fecha;
    } else if (fecha is Timestamp) {
      dt = fecha.toDate();
    } else if (fecha is String) {
      dt = DateTime.tryParse(fecha);
    } else if (fecha is Map && fecha.containsKey('_seconds')) {
      dt = DateTime.fromMillisecondsSinceEpoch(fecha['_seconds'] * 1000);
    }
    if (dt == null) return 'Sin fecha';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'en progreso':
        return AppColors.primary;
      case 'pendiente':
        return Colors.grey.shade500;
      default:
        return AppColors.cardBorder; // finalizadas u otros
    }
  }

  /// --- Card (re-utilizable) ----------------------------------------------

  Widget _solicitudCard(Map<String, dynamic> item) {
    final monto = item['monto'];
    final estado = (item['estado'] ?? '').toString().toLowerCase();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Row(
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
            if (monto != null)
              Text(
                'Bs. $monto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 15,
                ),
              ),
            if (estado == 'pendiente' || estado == 'en progreso')
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _estadoColor(estado),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  estado == 'pendiente' ? 'Pendiente' : 'En progreso',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['descripcion'] ?? 'Sin descripción',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.login, size: 14, color: Colors.grey),
                const SizedBox(width: 3),
                Text(
                  'Entrada: ${_formatFecha(item['entrada'])}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.logout, size: 14, color: Colors.grey),
                const SizedBox(width: 3),
                Text(
                  'Salida: ${_formatFecha(item['salida'])}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// --- UI -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'PuenteLaboral',
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
        child: StreamBuilder<List>(
          stream: getSolicitudesRealtimeByEmpleador(empleadorId),
          builder: (context, snapshotSolicitudes) {
            if (snapshotSolicitudes.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshotSolicitudes.hasError) {
              return Text('Error en solicitudes: ${snapshotSolicitudes.error}');
            }

            final solicitudes =
                snapshotSolicitudes.data?.cast<Map<String, dynamic>>() ?? [];

            return StreamBuilder<List>(
              stream: getHistorialRealtimeByEmpleador(empleadorId),
              builder: (context, snapshotHistorial) {
                if (snapshotHistorial.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshotHistorial.hasError) {
                  return Text('Error en historial: ${snapshotHistorial.error}');
                }

                final historial =
                    snapshotHistorial.data?.cast<Map<String, dynamic>>() ?? [];

                final enCurso =
                    historial
                        .where(
                          (e) =>
                              e['estado'] == 'pendiente' ||
                              e['estado'] == 'en progreso',
                        )
                        .toList();

                final completadas =
                    historial
                        .where((e) => e['estado'] == 'completada')
                        .toList();

                final canceladas =
                    historial.where((e) => e['estado'] == 'cancelada').toList();

                final otras =
                    historial
                        .where(
                          (e) =>
                              !(e['estado'] == 'pendiente' ||
                                  e['estado'] == 'en progreso' ||
                                  e['estado'] == 'completada' ||
                                  e['estado'] == 'cancelada'),
                        )
                        .toList();

                return ListView(
                  children: [
                    /// --- SECCIÓN: SOLICITUDES ---
                    if (solicitudes.isNotEmpty) ...[
                      Text(
                        'Solicitudes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...solicitudes.map(_solicitudCard),
                      const SizedBox(height: 24),
                    ],

                    /// --- SECCIÓN: HISTORIAL ---
                    if (enCurso.isNotEmpty) ...[
                      Text(
                        'Solicitudes en curso',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...enCurso.map(_solicitudCard),
                      const SizedBox(height: 24),
                    ],
                    if (completadas.isNotEmpty) ...[
                      Text(
                        'Solicitudes completadas',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...completadas.map(_solicitudCard),
                      const SizedBox(height: 24),
                    ],
                    if (canceladas.isNotEmpty) ...[
                      Text(
                        'Solicitudes canceladas',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...canceladas.map(_solicitudCard),
                      const SizedBox(height: 24),
                    ],
                    if (otras.isNotEmpty) ...[
                      Text(
                        'Otras solicitudes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...otras.map(_solicitudCard),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 80),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RequestStep1Page()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
