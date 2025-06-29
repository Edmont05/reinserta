import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../theme/app_colors.dart';
import 'request_step2_page.dart';

class RequestStep1Page extends StatefulWidget {
  const RequestStep1Page({super.key});

  @override
  State<RequestStep1Page> createState() => _RequestStep1PageState();
}

class _RequestStep1PageState extends State<RequestStep1Page> {
  String profesion = '';
  String trabajadores = '';
  DateTime? fechaInicio;
  DateTime? fechaFin;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;
  String monto = '';

  final montoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final trabajadoresController = TextEditingController();

  final decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d+\.?\d{0,2}'),
  );

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

  Future<void> _pickTimeRange() async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (start == null) return;
    final end = await showTimePicker(context: context, initialTime: start);
    if (end == null) return;
    setState(() {
      horaInicio = start;
      horaFin = end;
    });
  }

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

                /// Profesión con DropdownSearch
                DropdownSearch<String>(
                  items: const ["Agricultor", "Obrero", "Ayudante"],
                  selectedItem: profesion.isEmpty ? null : profesion,
                  popupProps: const PopupProps.menu(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Profesión requerida",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (value) => setState(() => profesion = value ?? ''),
                ),
                const SizedBox(height: 12),

                /// Número de trabajadores (igual)
                TextFormField(
                  controller: trabajadoresController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Número de trabajadores',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => trabajadores = val),
                ),

                /// Fechas
                Row(
                  children: [
                    Expanded(
                      child: _EntryCard(
                        label: 'Fecha de inicio',
                        value:
                        fechaInicio != null
                            ? "${fechaInicio!.day.toString().padLeft(2, '0')}/${fechaInicio!.month.toString().padLeft(2, '0')}/${fechaInicio!.year}"
                            : '',
                        onTap: () => _pickDate(context, true),
                        placeholder: 'dd/mm/aaaa',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EntryCard(
                        label: 'Fecha fin',
                        value:
                        fechaFin != null
                            ? "${fechaFin!.day.toString().padLeft(2, '0')}/${fechaFin!.month.toString().padLeft(2, '0')}/${fechaFin!.year}"
                            : '',
                        onTap: () => _pickDate(context, false),
                        placeholder: 'dd/mm/aaaa',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Horario con time pickers
                _EntryCard(
                  label: 'Horario',
                  value:
                  (horaInicio != null && horaFin != null)
                      ? '${horaInicio!.format(context)} - ${horaFin!.format(context)}'
                      : '',
                  onTap: _pickTimeRange,
                  placeholder: 'Seleccionar',
                ),
                const SizedBox(height: 12),

                /// Monto como decimal input
                TextFormField(
                  controller: montoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [decimalFormatter],
                  decoration: InputDecoration(
                    labelText: "Monto por persona",
                    border: OutlineInputBorder(),
                    prefixText: "\$",
                  ),
                  onChanged: (val) => setState(() => monto = val),
                ),

                const SizedBox(height: 28),

                /// Botón Siguiente
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
                          horaInicio == null ||
                          horaFin == null ||
                          monto.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Completa todos los campos'),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RequestStep2Page(
                            profesion: profesion,
                            trabajadores: trabajadores,
                            fechaInicio: fechaInicio!,
                            fechaFin: fechaFin!,
                            horario:
                            '${horaInicio!.format(context)} - ${horaFin!.format(context)}',
                            monto: monto,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Siguiente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white, // <-- blanco
                      ),
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
                      color:
                      value.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight:
                      value.isNotEmpty
                          ? FontWeight.bold
                          : FontWeight.normal,
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
      children:
      options
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