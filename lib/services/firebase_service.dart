import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

/// Inserta múltiples usuarios en batch
Future<void> addWorkersBatch(List<Map<String, dynamic>> workers) async {
  WriteBatch batch = db.batch();

  for (var worker in workers) {
    var docRef = db.collection('Users').doc();
    batch.set(docRef, worker);
  }

  await batch.commit();
}
Future<void> addSolicitudes(BuildContext context) async {
  final random = Random();

  final professions = [
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

  final descriptions = [
    "Necesito trabajo urgente en casa.",
    "Requiere experiencia en proyectos grandes.",
    "Trabajo sencillo, pero se necesita precisión.",
    "Cliente exigente, se ofrece buen pago.",
    "Tarea rápida y puntual.",
    "Proyecto para empresa.",
    "Necesidad de reparación inmediata.",
    "Mantenimiento preventivo solicitado.",
    "Mejorar instalaciones existentes.",
    "Revisión general de sistemas.",
  ];

  String description = descriptions[random.nextInt(descriptions.length)];
  String profession = professions[random.nextInt(professions.length)];
  int cantidad = random.nextInt(5) + 1;

  DateTime now = DateTime.now();
  Duration diff;

  int option = random.nextInt(3);
  switch (option) {
    case 0:
      diff = Duration(days: 1);
      break;
    case 1:
      diff = Duration(days: 7);
      break;
    case 2:
      diff = Duration(days: 120);
      break;
    default:
      diff = Duration(days: 1);
  }

  DateTime entrada = now;
  DateTime salida = now.add(diff);

  double lat = -17.9 + random.nextDouble() * (0.3);
  double lng = -63.3 + random.nextDouble() * (0.3);
  double monto = (random.nextDouble() * 450) + 50;

  try {
    await addSolicitud(
      cantidad: cantidad,
      descripcion: description,
      entrada: entrada,
      estado: "pendiente",
      latitud: lat.toStringAsFixed(6),
      longitud: lng.toStringAsFixed(6),
      monto: double.parse(monto.toStringAsFixed(2)),
      profesion: profession,
      salida: salida,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("¡Solicitud aleatoria agregada!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al agregar solicitud: $e")),
    );
  }
}

Future<void> addSolicitud({
  required int cantidad,
  required String descripcion,
  required DateTime entrada,
  required String estado,
  required String latitud,
  required String longitud,
  required double monto,
  required String profesion,
  required DateTime salida,
}) async {
  await db.collection('Solicitudes').add({
    'cantidad': cantidad,
    'descripcion': descripcion,
    'entrada': Timestamp.fromDate(entrada),
    'estado': estado,
    'latitud': latitud,
    'longitud': longitud,
    'monto': monto,
    'profesion': profesion,
    'salida': Timestamp.fromDate(salida),
  });
}

Future<void> addHistorial({
  required int cantidad,
  required String descripcion,
  required DateTime entrada,
  required DateTime salida,
  required double latitud,
  required double longitud,
  required double monto,
  required String profesion,
  required double calificacion,
  required String comentario,
  required String empleado,
  required String empleador,
}) async {
  await db.collection('Historial').add({
    'cantidad': cantidad,
    'descripcion': descripcion,
    'entrada': Timestamp.fromDate(entrada),
    'salida': Timestamp.fromDate(salida),
    'latitud': latitud.toStringAsFixed(6),
    'longitud': longitud.toStringAsFixed(6),
    'monto': monto,
    'profesion': profesion,
    'calificacion': calificacion,
    'comentario': comentario,
    'empleado': empleado,
    'empleador': empleador,
  });
}

Future<void> addHistorialFicticio(BuildContext context) async {
  final random = Random();

  final professions = [
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

  final descriptions = [
    "Reparación urgente completada.",
    "Trabajo de alta calidad.",
    "Cliente satisfecho con el servicio.",
    "Pequeños detalles por mejorar.",
    "Trabajo entregado a tiempo.",
    "Excelente experiencia.",
    "Atención rápida y eficiente.",
    "Trabajo profesional.",
    "Muy buen resultado.",
    "Totalmente recomendable.",
  ];

  final comentarios = [
    "Excelente servicio.",
    "Podría mejorar.",
    "Quedé satisfecho.",
    "No fue lo esperado.",
    "Muy amable y puntual.",
    "Trabajo impecable.",
    "Repetiría sin dudar.",
    "Buena relación calidad-precio.",
    "Atento y responsable.",
    "Buen trato y resultado.",
  ];

  String descripcion = descriptions[random.nextInt(descriptions.length)];
  String comentario = comentarios[random.nextInt(comentarios.length)];
  String profesion = professions[random.nextInt(professions.length)];
  int cantidad = random.nextInt(5) + 1;
  double calificacion = (random.nextDouble() * 2) + 3; // entre 3.0 y 5.0
  double monto = (random.nextDouble() * 450) + 50; // entre 50 y 500

  // Fechas
  DateTime now = DateTime.now();
  Duration diff;
  int option = random.nextInt(3);
  switch (option) {
    case 0:
      diff = Duration(days: 1);
      break;
    case 1:
      diff = Duration(days: 7);
      break;
    case 2:
      diff = Duration(days: 120);
      break;
    default:
      diff = Duration(days: 1);
  }
  DateTime entrada = now;
  DateTime salida = now.add(diff);

  // Coordenadas Santa Cruz
  double lat = -17.9 + random.nextDouble() * (0.3);
  double lng = -63.3 + random.nextDouble() * (0.3);

  try {
    await addHistorial(
      cantidad: cantidad,
      descripcion: descripcion,
      entrada: entrada,
      salida: salida,
      latitud: lat,
      longitud: lng,
      monto: double.parse(monto.toStringAsFixed(2)),
      profesion: profesion,
      calificacion: double.parse(calificacion.toStringAsFixed(1)),
      comentario: comentario,
      empleado: "JzPcgomrS0RSamAeFAx7",
      empleador: "JzPcgomrS0RSamAeFAx7",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("¡Historial ficticio agregado!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al agregar historial: $e")),
    );
  }
}