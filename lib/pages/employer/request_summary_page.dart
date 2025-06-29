import 'package:flutter/material.dart';
import 'package:reinserta/services/firebase_services.dart' as fb;
import '../../theme/app_colors.dart';
import 'employer_history_page.dart';

class RequestSummaryPage extends StatefulWidget {
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
  State<RequestSummaryPage> createState() => _RequestSummaryPageState();
}

class _RequestSummaryPageState extends State<RequestSummaryPage> {
  bool _publicando = false;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppColors.primary),
        centerTitle: true,
        title: Image.asset('img/logo.png', height: 48),
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
                      _row('Profesión requerida', widget.profesion),
                      _row('Número de trabajadores', widget.trabajadores),
                      _row('Fecha',
                          '${_fmt(widget.fechaInicio)} - ${_fmt(widget.fechaFin)}'),
                      _row('Horario', widget.horario),
                      _row('Monto por persona', widget.monto),
                      _row('Ubicación', widget.ubicacion),
                      const SizedBox(height: 8),
                      const Text('Descripción',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.descripcion,
                          style: const TextStyle(fontSize: 15)),
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
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _publicando ? null : _guardarYPublicar,
                  child: _publicando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Publicar solicitud',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Guarda en Firestore, genera candidatos (IA) y navega al historial
  Future<void> _guardarYPublicar() async {
    setState(() => _publicando = true);

    try {
      await fb.publicarSolicitud(
        cantidad: int.parse(widget.trabajadores),
        descripcion: widget.descripcion,
        horario: widget.horario,
        entrada: widget.fechaInicio,
        latitud: '0',               // <-- añade tu lat/lon reales
        longitud: '0',
        monto: double.parse(widget.monto),
        profesion: widget.profesion,
        salida: widget.fechaFin,
        empleadorId: '1JSngNx7QxeeEBC6lPWW', // <-- empleador autenticado
      );

      // Redirige y limpia el stack
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const EmployerHistoryPage()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 3,
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ),
          ],
        ),
      );
}
