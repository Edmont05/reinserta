import 'package:flutter/material.dart';
import 'package:reinserta/firebase_options.dart';
import 'package:reinserta/services/firebase_service.dart'; // <-- importa tu servicio aquí
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loading = false;
  String? _message;

  void _addWorkersBatch() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    final random = Random();

    final List<String> names = [
      "Juan Pérez",
      "Pedro Gómez",
      "María Flores",
      "Ana López",
      "Luis Vargas",
      "Carla Rojas",
      "José Salazar",
      "Paola Díaz",
      "Diego Castro",
      "Rosa Gutiérrez",
      "Fernando Lima",
      "Patricia Ramírez",
      "Sergio Molina",
      "Camila Fuentes",
      "Eduardo Ochoa",
      "Cecilia Blanco",
      "Manuel Ortega",
      "Laura Suárez",
      "Esteban Méndez",
      "Mónica Silva",
    ];

    final List<String> professions = [
      "gasfitero",
      "electricista",
      "carpintero",
      "albañil",
      "pintor",
      "jardinero",
      "cerrajero",
      "plomero",
      "soldador",
      "técnico en refrigeración",
    ];

    List<Map<String, dynamic>> workers = [];

    for (int i = 0; i < 20; i++) {
      double lat = -17.9 + random.nextDouble() * (0.3);
      double lng = -63.3 + random.nextDouble() * (0.3);
      double rating = (random.nextDouble() * 1.5) + 3.5;
      int range = random.nextInt(5) + 1;

      workers.add({
        'nombre': names[random.nextInt(names.length)],
        'profesion': professions[random.nextInt(professions.length)],
        'calificacion': double.parse(rating.toStringAsFixed(1)),
        'rango': range,
        'lat': double.parse(lat.toStringAsFixed(6)),
        'lng': double.parse(lng.toStringAsFixed(6)),
        'descripcion': "Experiencia en trabajos residenciales y comerciales.",
        'estado': true,
      });
    }

    try {
      await addWorkersBatch(workers);

      setState(() {
        _message = "¡Se agregaron 20 trabajadores aleatorios!";
      });
    } catch (e) {
      setState(() {
        _message = "Error al agregar trabajadores: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _addSolicitud() async {
    try {
      await addSolicitud(
        cantidad: 3,
        descripcion: "",
        entrada: DateTime(2025, 6, 28),
        estado: "pendiente",
        latitud: "13456464",
        longitud: "31854183",
        monto: 200,
        profesion: "Carpintero",
        salida: DateTime(2025, 6, 28),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("¡Solicitud agregada correctamente!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al agregar solicitud: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child:
            _loading
                ? CircularProgressIndicator()
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addWorkersBatch,
                      icon: Icon(Icons.person_add),
                      label: Text("Agregar Workers"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _addSolicitud,
                      icon: Icon(Icons.note_add),
                      label: Text("Agregar Solicitud"),
                    ),
                    ElevatedButton(
                      onPressed: () => addSolicitudes(context),
                      child: Text("Agregar Solicitud"),
                    ),
                    ElevatedButton(
                      onPressed: () => addHistorialFicticio(context),
                      child: Text("Agregar Historial"),
                    ),
                  ],
                ),
      ),
    );
  }
}
