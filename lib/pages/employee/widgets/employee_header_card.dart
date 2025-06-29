import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'package:reinserta/services/firebase_services.dart';

class EmployeeHeaderCard extends StatelessWidget {
  final String empleadoId;
  const EmployeeHeaderCard({super.key, required this.empleadoId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: getEmpleadoRealtimeById(empleadoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Empleado no encontrado');
        }

        final empleado = snapshot.data!;
        final empleadoMap = {
          'title': empleado['nombre'] ?? 'Sin nombre',
          'description': empleado['detalle'] ?? 'Sin detalle',
          'estado': empleado['estado'],
        };

        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: empleadoMap['estado'] ? AppColors.primary : AppColors.coral,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: empleadoMap['estado']
                      ? AppColors.primary.withOpacity(0.08)
                      : AppColors.coral.withOpacity(0.15),
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.check_circle,
                  color: empleadoMap['estado'] ? AppColors.primary : AppColors.coral,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                empleadoMap['estado'] ? "Disponible" : "No disponible",
                style: TextStyle(
                  color: empleadoMap['estado'] ? AppColors.primary : AppColors.coral,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Switch(
                value: empleadoMap['estado'] ?? false,
                onChanged: (value) async {
                  await updateEstadoEmpleado(empleadoId, value);
                },
                activeColor: AppColors.primary,
                inactiveThumbColor: AppColors.coral,
                inactiveTrackColor: AppColors.coral.withOpacity(0.4),
              ),
            ],
          ),
        );
      },
    );
  }
}