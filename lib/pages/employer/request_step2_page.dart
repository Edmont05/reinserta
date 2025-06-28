import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'request_summary_page.dart';

class RequestStep2Page extends StatefulWidget {
  final String profesion;
  final String trabajadores;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String horario;
  final String monto;

  const RequestStep2Page({
    super.key,
    required this.profesion,
    required this.trabajadores,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horario,
    required this.monto,
  });

  @override
  State<RequestStep2Page> createState() => _RequestStep2PageState();
}

class _RequestStep2PageState extends State<RequestStep2Page> {
  String ubicacion = '';
  String descripcion = '';

  @override
  Widget build(BuildContext context) {
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
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Crear Solicitud',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _EntryCard(
                label: 'Ubicación',
                value: ubicacion,
                onTap: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (ctx) => _PickerDialog(
                      title: "Selecciona ubicación",
                      options: const [
                        "Av. Las Rosas 234",
                        "Finca Los Pinos",
                        "Col. Centro 123",
                      ],
                    ),
                  );
                  if (result != null) setState(() => ubicacion = result);
                },
                placeholder: 'Ingresar ubicación',
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final controller = TextEditingController(text: descripcion);
                  final result = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Descripción"),
                      content: TextField(
                        controller: controller,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Recolección de papas en el campo",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, controller.text),
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  );
                  if (result != null) setState(() => descripcion = result);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descripción',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descripcion.isNotEmpty ? descripcion : "Recolección de papas en el campo",
                        style: TextStyle(
                          color: descripcion.isNotEmpty
                              ? AppColors.textPrimary
                              : AppColors.textSecondary.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: descripcion.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (ubicacion.isEmpty || descripcion.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Completa todos los campos')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestSummaryPage(
                          profesion: widget.profesion,
                          trabajadores: widget.trabajadores,
                          fechaInicio: widget.fechaInicio,
                          fechaFin: widget.fechaFin,
                          horario: widget.horario,
                          monto: widget.monto,
                          ubicacion: ubicacion,
                          descripcion: descripcion,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Siguiente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

// Puedes reutilizar los EntryCard y PickerDialog de request_step1_page
class _EntryCard extends StatelessWidget {
  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;
  const _EntryCard({
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : placeholder,
                    style: TextStyle(
                      color: value.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: value.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.cardBorder),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerDialog extends StatelessWidget {
  final String title;
  final List<String> options;
  const _PickerDialog({required this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      children: options
          .map(
            (o) => SimpleDialogOption(
          child: Text(o),
          onPressed: () => Navigator.pop(context, o),
        ),
      )
          .toList(),
    );
  }
}