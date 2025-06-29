import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'employer/employer_history_page.dart';
import 'employee/employee_main_page.dart';
import '../services/gemini_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;

  Future<void> _testGemini() async {
    setState(() => _loading = true);
    try {
      final result = await GeminiService.generateContent(
        'Escribe una frase motivadora sobre la igualdad de oportunidades laborales.',
      );
      _showDialog('Respuesta de Gemini', result);
    } catch (e) {
      _showDialog('Error', e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset('img/logo.png', height: 90),
                  const SizedBox(height: 28),
                  Text(
                    'Bienvenido a Reinserta!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '¿Cómo quieres iniciar sesión?',
                    style: TextStyle(fontSize: 16, color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 38),

                  // Botón Trabajador
                  _roleButton(
                    icon: Icons.handyman,
                    label: 'Trabajador',
                    isFilled: false,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployeeMainPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Botón Empleador
                  _roleButton(
                    icon: Icons.business_center,
                    label: 'Empleador',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployerHistoryPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Botón Probar Gemini
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      label: Text(
                        _loading ? 'Consultando…' : 'Probar Gemini AI',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading ? null : _testGemini,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper para los botones de rol
  Widget _roleButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isFilled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isFilled
          ? ElevatedButton.icon(
              icon: Icon(icon, color: Colors.white),
              label: Text(label,
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: onTap,
            )
          : OutlinedButton.icon(
              icon: Icon(icon, color: AppColors.primary),
              label: Text(label,
                  style: TextStyle(fontSize: 18, color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              onPressed: onTap,
            ),
    );
  }
}
