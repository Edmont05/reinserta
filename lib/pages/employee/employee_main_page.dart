import 'package:flutter/material.dart';
import 'package:reinserta/services/firebase_services.dart';
import '../../theme/app_colors.dart';

class EmployeeMainPage extends StatefulWidget {
  const EmployeeMainPage({super.key});

  @override
  State<EmployeeMainPage> createState() => _EmployeeMainPageState();
}

class _EmployeeMainPageState extends State<EmployeeMainPage> {
  bool isAvailable = true;
  int _selectedIndex = 0; // 0: Historial, 1: Ofertas

  // Demo data for jobs and offers
  final List<Map<String, String>> allPastJobs = [
    {'title': 'Solicitud 1', 'description': 'Descripción de la solicitud 1'},
    {'title': 'Solicitud 2', 'description': 'Descripción de la solicitud 2'},
    {'title': 'Solicitud 3', 'description': 'Descripción de la solicitud 3'},
  ];

  final List<Map<String, String>> currentOffers = [
    {
      'title': 'Solicitud A',
      'description': 'Aceptada el 15 de junio de 2025.',
      'status': 'En progreso',
    },
    {
      'title': 'Solicitud B',
      'description': 'Aceptada el 10 de junio de 2025.',
      'status': 'Pendiente',
    },
    {
      'title': 'Solicitud C',
      'description': 'Aceptada el 1 de junio de 2025.',
      'status': 'Pendiente',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            Navigator.canPop(context)
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
            // Only show switch on Ofertas page
            if (_selectedIndex == 1) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAvailable ? AppColors.primary : AppColors.coral,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isAvailable
                                ? AppColors.primary.withOpacity(0.08)
                                : AppColors.coral.withOpacity(0.15),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.check_circle,
                        color:
                            isAvailable ? AppColors.primary : AppColors.coral,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isAvailable ? "Disponible" : "No disponible",
                      style: TextStyle(
                        color:
                            isAvailable ? AppColors.primary : AppColors.coral,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() => isAvailable = value);
                      },
                      activeColor: AppColors.primary,
                      inactiveThumbColor: AppColors.coral,
                      inactiveTrackColor: AppColors.coral.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (_selectedIndex == 0) ...[
              // Card de confiabilidad (sin cambios)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.reliableBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.reliableIconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Confiable',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.4,
                              backgroundColor: AppColors.progressBg,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '4/10',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Título
              Text(
                'Trabajos anteriores',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Aquí el StreamBuilder que trae los datos
              StreamBuilder<List>(
                stream: getHistorialRealtime(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay historial');
                  }

                  final historial = snapshot.data!.cast<Map<String, dynamic>>();

                  return Column(
                    children: [
                      ...historial.map((item) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            title: Text(
                              item['profesion'] ?? 'Sin profesion',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              item['descripcion'] ?? 'Sin descripción',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ],

            if (_selectedIndex == 0) ...[
              // Historial: rango y lista de trabajos anteriores
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.reliableBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.reliableIconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Confiable',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Rango bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: 0.4, // Ejemplo: 4/10
                            backgroundColor: AppColors.progressBg,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '4/10',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'Trabajos anteriores',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...allPastJobs.map((item) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    title: Text(
                      item['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      item['description']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
            if (_selectedIndex == 1) ...[
              Text(
                'Ofertas vigentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...currentOffers
                  .where(
                    (item) =>
                        item['status'] == 'En progreso' ||
                        item['status'] == 'Pendiente',
                  )
                  .map((item) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (item['status'] == 'Pendiente') ...[
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                tooltip: 'Rechazar',
                                onPressed: () {
                                  // Acción de rechazar aquí
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                tooltip: 'Aceptar',
                                onPressed: () {
                                  // Acción de aceptar aquí
                                },
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          item['description']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing:
                            item['status'] == 'En progreso'
                                ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'En progreso',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                    );
                  })
                  .toList(),
            ],
            const SizedBox(height: 80),
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
