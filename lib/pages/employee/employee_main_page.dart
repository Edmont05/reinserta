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