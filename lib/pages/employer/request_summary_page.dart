import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class RequestSummaryPage extends StatelessWidget {
  final String profesion;
  final String trabajadores;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String horario;
  final String monto;
  final String ubicacion;
  final String descripcion;

  const RequestSummaryPage({
    super.key,
    required this.profesion,
    required this.trabajadores,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horario,
    required this.monto,
    required this.ubicacion,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppColors.primary),
        centerTitle: true,
        title: Image.asset(
          'img/logo.png',
          height: 48,
        ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Resumen',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: ListView(
                    children: [
                      _SummaryRow(label: 'Profesión requerida', value: profesion),
                      _SummaryRow(label: 'Número de trabajadores', value: trabajadores),
                      _SummaryRow(
                        label: 'Fecha',
                        value: "${formatDate(fechaInicio)} - ${formatDate(fechaFin)}",
                      ),
                      _SummaryRow(label: 'Horario', value: horario),
                      _SummaryRow(label: 'Monto por persona', value: monto),
                      _SummaryRow(label: 'Ubicación', value: ubicacion),
                      const SizedBox(height: 8),
                      const Text(
                        "Descripción",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        descripcion,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Acción para publicar la solicitud
                    Navigator.popUntil(context, (route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Solicitud publicada')),
                    );
                  },
                  child: const Text(
                    'Publicar solicitud',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}