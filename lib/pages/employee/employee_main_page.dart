import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/app_colors.dart';
import './widgets/employee_header_card.dart';
import './widgets/employee_history_section.dart';
import './widgets/employee_offers_section.dart';

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
      pw.MultiPage(
        build: (context) => [
          pw.Text("Extracto de trabajos realizados", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          ...historial.map((item) {
            DateTime entradaDate;
            DateTime salidaDate;

            if (item['entrada'] is Map && item['entrada'].containsKey('_seconds')) {
              entradaDate = DateTime.fromMillisecondsSinceEpoch(item['entrada']['_seconds'] * 1000);
            } else {
              entradaDate = DateTime.tryParse(item['entrada'].toString()) ?? DateTime.now();
            }

            if (item['salida'] is Map && item['salida'].containsKey('_seconds')) {
              salidaDate = DateTime.fromMillisecondsSinceEpoch(item['salida']['_seconds'] * 1000);
            } else {
              salidaDate = DateTime.tryParse(item['salida'].toString()) ?? DateTime.now();
            }

            String twoDigits(int n) => n.toString().padLeft(2, '0');
            String fechaHora(DateTime dt) =>
                "${twoDigits(dt.day)}/${twoDigits(dt.month)}/${dt.year} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}";

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5, color: PdfColor.fromHex('#cccccc')),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(item['profesion'] ?? 'Sin profesión', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                      if (item['monto'] != null)
                        pw.Text("Bs. ${item['monto']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  if (item['descripcion'] != null)
                    pw.Text(item['descripcion'], style: pw.TextStyle(fontSize: 11)),
                  pw.Text("Entrada: ${fechaHora(entradaDate)}", style: pw.TextStyle(fontSize: 11)),
                  pw.Text("Salida: ${fechaHora(salidaDate)}", style: pw.TextStyle(fontSize: 11)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
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
          _selectedIndex == 0 ? 'Historial' : 'Reinserta',
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
              EmployeeHistorySection(onPrint: _printPDFExtract),
            if (_selectedIndex == 1)
              EmployeeOffersSection(empleadoId: empleadoId),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
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