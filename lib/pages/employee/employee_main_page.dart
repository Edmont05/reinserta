import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/app_colors.dart';
import './widgets/employee_header_card.dart';
import './widgets/employee_history_section.dart';
import './widgets/employee_offers_section.dart';
import '../../services/employee_ai_service.dart';

const String empleadoId = '4EjLmDUh7rNte4DI2mf3';

class EmployeeMainPage extends StatefulWidget {
  const EmployeeMainPage({super.key});

  @override
  State<EmployeeMainPage> createState() => _EmployeeMainPageState();
}

class _EmployeeMainPageState extends State<EmployeeMainPage> {
  int _selectedIndex = 0;

  Future<void> _printPDFExtract(List<Map<String, dynamic>> historial) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Historial del Empleado', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              if (historial.isEmpty)
                pw.Text('No hay historial disponible.', style: pw.TextStyle(fontSize: 16)),
              ...historial.map((item) => pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.only(bottom: 20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                  borderRadius: pw.BorderRadius.circular(6),
                  color: PdfColors.white,
                ),
                padding: const pw.EdgeInsets.all(14),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Profesión: ${item['profesion'] ?? 'Sin profesión'}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Descripción: ${item['descripcion'] ?? 'Sin descripción'}', style: const pw.TextStyle(fontSize: 13)),
                    pw.SizedBox(height: 6),
                    pw.Text('Entrada: ${_formatFecha(item['entrada'])}', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('Salida: ${_formatFecha(item['salida'])}', style: const pw.TextStyle(fontSize: 12)),
                    if (item['monto'] != null)
                      pw.Text('Monto: Bs. ${item['monto']}', style: const pw.TextStyle(fontSize: 12)),
                    if (item['estado'] != null)
                      pw.Text('Estado: ${item['estado']}', style: pw.TextStyle(fontSize: 12, color: PdfColors.black)),
                  ],
                ),
              )),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  String _formatFecha(dynamic fecha) {
    DateTime? dt;
    if (fecha == null) return 'Sin fecha';
    if (fecha is DateTime) dt = fecha;
    else if (fecha is String) dt = DateTime.tryParse(fecha);
    else if (fecha is Map && fecha.containsKey('_seconds')) {
      dt = DateTime.fromMillisecondsSinceEpoch(fecha['_seconds'] * 1000);
    } else if (fecha is Timestamp) {
      dt = fecha.toDate();
    } else if (fecha is dynamic && fecha.toString().contains('Timestamp')) {
      try {
        dt = (fecha as dynamic).toDate();
      } catch (_) {}
    }
    if (dt == null) return 'Sin fecha';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(dt.day)}/${twoDigits(dt.month)}/${dt.year} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
        title: Text(
          _selectedIndex == 0 ? 'Historial' : 'PuenteLaboral',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.cardBg,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
          children: [
            const EmployeeHeaderCard(empleadoId: empleadoId),
            if (_selectedIndex == 0)
              EmployeeHistorySection(
                empleadoId: empleadoId,
                onPrint: _printPDFExtract,
              ),
            if (_selectedIndex == 1)
              EmployeeOffersSection(empleadoId: empleadoId),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) async {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            await getUltimoHistorialEmpleado(empleadoId);
          }
        },
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.primary.withOpacity(0.4),
        elevation: 6,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Ofertas',
          ),
        ],
      ),
    );
  }
}