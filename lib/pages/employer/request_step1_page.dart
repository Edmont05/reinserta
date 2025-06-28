import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'request_step2_page.dart';

class RequestStep1Page extends StatefulWidget {
  const RequestStep1Page({super.key});

  @override
  State<RequestStep1Page> createState() => _RequestStep1PageState();
}

class _RequestStep1PageState extends State<RequestStep1Page> {
  // Controllers y estados
  String profesion = '';
  String trabajadores = '';
  DateTime? fechaInicio;
  DateTime? fechaFin;
  String horario = '';
  String monto = '';

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          fechaInicio = picked;
        } else {
          fechaFin = picked;
        }
      });
    }
  }

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
          child: Form(
            key: _formKey,
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
                  label: 'Profesión requerida',
                  value: profesion,
                  onTap: () async {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (ctx) => _PickerDialog(
                        title: "Selecciona profesión",
                        options: const ["Agricultor", "Obrero", "Ayudante"],
                      ),
                    );
                    if (result != null) setState(() => profesion = result);
                  },
                  placeholder: 'Seleccionar',
                ),
                const SizedBox(height: 12),
                _EntryCard(
                  label: 'Numero de trabajadores',
                  value: trabajadores,
                  onTap: () async {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (ctx) => _PickerDialog(
                        title: "Cantidad de trabajadores",
                        options: List.generate(20, (i) => '${i + 1}'),
                      ),
                    );
                    if (result != null) setState(() => trabajadores = result);
                  },
                  placeholder: '0',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _EntryCard(
                        label: 'Fecha de inicio',
                        value: fechaInicio != null
                            ? "${fechaInicio!.day.toString().padLeft(2, '0')}/${fechaInicio!.month.toString().padLeft(2, '0')}/${fechaInicio!.year}"
                            : '',
                        onTap: () => _pickDate(context, true),
                        placeholder: 'dd/mm/aaaa',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EntryCard(
                        label: 'Fecha dfn',
                        value: fechaFin != null
                            ? "${fechaFin!.day.toString().padLeft(2, '0')}/${fechaFin!.month.toString().padLeft(2, '0')}/${fechaFin!.year}"
                            : '',
                        onTap: () => _pickDate(context, false),
                        placeholder: 'dd/mm/aaaa',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _EntryCard(
                  label: 'Horario',
                  value: horario,
                  onTap: () async {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (ctx) => _PickerDialog(
                        title: "Horario",
                        options: const [
                          "8:00 a.m. - 2:00 p.m.",
                          "2:00 p.m. - 8:00 p.m.",
                        ],
                      ),
                    );
                    if (result != null) setState(() => horario = result);
                  },
                  placeholder: 'Seleccionar',
                ),
                const SizedBox(height: 12),
                _EntryCard(
                  label: 'Monto por persona',
                  value: monto,
                  onTap: () async {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (ctx) => _PickerDialog(
                        title: "Monto por persona",
                        options: const ["\$150", "\$200", "\$250"],
                      ),
                    );
                    if (result != null) setState(() => monto = result);
                  },
                  placeholder: '\$0',
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
                      if (profesion.isEmpty ||
                          trabajadores.isEmpty ||
                          fechaInicio == null ||
                          fechaFin == null ||
                          horario.isEmpty ||
                          monto.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa todos los campos')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestStep2Page(
                            profesion: profesion,
                            trabajadores: trabajadores,
                            fechaInicio: fechaInicio!,
                            fechaFin: fechaFin!,
                            horario: horario,
                            monto: monto,
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
      ),
    );
  }
}

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