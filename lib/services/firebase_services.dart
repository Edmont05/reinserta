import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:reinserta/services/gemini_service.dart';

FirebaseFirestore db = FirebaseFirestore.instance;



int calcularRangoMinimo(DateTime fechaInicio, DateTime fechaFin) {
  final diferencia = fechaFin.difference(fechaInicio);

  if (diferencia.inDays < 7) {
    // Menos de 1 semana
    return 1;
  } else if (diferencia.inDays < 30) {
    // 1 semana hasta menos de 1 mes
    return 2;
  } else if (diferencia.inDays < 180) {
    // 1 mes hasta menos de 6 meses
    return 3;
  } else {
    // 6 meses o más
    return 4;
  }
}

Stream<List> getHistorialRealtime() {
  CollectionReference collectionReferenceHistorial = db.collection('Historial');
  return collectionReferenceHistorial
      .orderBy('salida', descending: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList(),
      );
}

Stream<List> getSolicitudesRealtime() {
  CollectionReference collectionReferenceSolicitudes = db.collection(
    'Solicitudes',
  );
  return collectionReferenceSolicitudes
      .orderBy('salida', descending: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList(),
      );
}

Stream<List> getHistorialRealtimeByEmpleador(String empleadorId) {
  CollectionReference collectionReferenceHistorial = db.collection('Historial');
  return collectionReferenceHistorial
      .where('empleador', isEqualTo: empleadorId)
      // .orderBy('salida', descending: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList(),
      );
}

Stream<List> getEmpleadosRealtime() {
  CollectionReference collectionReferenceEmpleados = db.collection(
    'Solicitudes',
  );
  return collectionReferenceEmpleados
      .where('estado', isEqualTo: true)
      // .where('rol', isEqualTo: 'empleado')
      .orderBy('nombre', descending: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList(),
      );
}

Stream<Map<String, dynamic>?> getEmpleadoFilter({
  required String empleadoId,
  required String profesionBuscada,
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) {
  final rangoMinimo = calcularRangoMinimo(fechaInicio, fechaFin);

  return db
      .collection('Users')
      .doc(empleadoId)
      .snapshots()
      .map((docSnapshot) {
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;

      final rol = data['rol'] as String?;
      final profesion = data['profesion'] as String?;
      final rango = data['rango'] as int?;

      if (rol == 'empleado' &&
          profesion == profesionBuscada &&
          rango != null &&
          rango >= rangoMinimo) {
        
        data['id'] = docSnapshot.id;

        if (rango == 4) {
          data['beneficio'] =
              'Tiene beneficio de trabajo formal o posibilidad de solicitarlo.';
        }

        return data;
      }
    }
    return null;
  });
}

Stream<Map<String, dynamic>?> getEmpleadoRealtimeById(String empleadoId) {
  return db.collection('Users').doc(empleadoId).snapshots().map((docSnapshot) {
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = docSnapshot.id;
      return data;
    } else {
      return null;
    }
  });
}


Stream<List> getEmpleadoresRealtime() {
  CollectionReference collectionReferenceEmpleadores = db.collection(
    'Solicitudes',
  );
  return collectionReferenceEmpleadores
      .where('rol', isEqualTo: 'empleador')
      .orderBy('nombre', descending: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList(),
      );
}

Future<void> updateEstadoEmpleado(String empleadoId, bool estado) async {
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(empleadoId)
      .update({'estado': estado});
}

Future<void> addHistorial({
  required double calificacion,
  required int cantidad,
  required String comentario,
  required String descripcion,
  required String horario,
  required String empleado,
  required String empleador,
  required DateTime entrada,
  required String latitud,
  required String longitud,
  required double monto,
  required String profesion,
  required DateTime salida,
}) async {
  await db.collection('Historial').add({
    "calificacion": calificacion,
    "cantidad": cantidad,
    "comentario": comentario,
    "descripcion": descripcion,
    "horario": horario,
    "empleado": empleado,
    "empleador": empleador,
    "entrada": Timestamp.fromDate(entrada),
    "latitud": latitud,
    "longitud": longitud,
    "monto": monto,
    "profesion": profesion,
    "salida": Timestamp.fromDate(salida),
  });
}

Future<void> completeSolicitudAndCreateHistorial({
  required String solicitudId,
  required String empleado,
  required String empleador,
  required double calificacion,
  required String comentario,
}) async {
  final docRef = db.collection('Solicitudes').doc(solicitudId);

  final snapshot = await docRef.get();

  if (snapshot.exists) {
    final data = snapshot.data() as Map<String, dynamic>;

    await docRef.update({'estado': 'completada', 'calificacion': calificacion});

    int cantidad = data['cantidad'] ?? 0;
    String descripcion = data['descripcion'] ?? '';
    String horario = data['descripcion'] ?? '';
    Timestamp entradaTimestamp = data['entrada'];
    DateTime entrada = entradaTimestamp.toDate();
    String latitud = data['latitud'] ?? '';
    String longitud = data['longitud'] ?? '';
    double monto = (data['monto'] ?? 0).toDouble();
    String profesion = data['profesion'] ?? '';
    Timestamp salidaTimestamp = data['salida'];
    DateTime salida = salidaTimestamp.toDate();

    await addHistorial(
      calificacion: calificacion,
      cantidad: cantidad,
      comentario: comentario,
      descripcion: descripcion,
      horario: horario,
      empleado: empleado,
      empleador: empleador,
      entrada: entrada,
      latitud: latitud,
      longitud: longitud,
      monto: monto,
      profesion: profesion,
      salida: salida,
    );
  } else {
    throw Exception("La solicitud con id $solicitudId no existe.");
  }
}

Stream<List> getHistorialDeEmpleadorRealtime(String empleadorId) {
  CollectionReference collectionReferenceHistorial = db.collection('Historial');
  return collectionReferenceHistorial
      .where('empleador', isEqualTo: empleadorId)
      .orderBy('salida', descending: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList(),
      );
}

Stream<List<Map<String, dynamic>>> getSolicitudesByEmpleadoRealtime(String empleadoId) async* {
  final candidatosRef = FirebaseFirestore.instance.collection('Candidatos');
  final solicitudesRef = FirebaseFirestore.instance.collection('Solicitudes');

  // Escucha los cambios en la relación (Candidatos)
  await for (final candidatosSnap in candidatosRef.where('empleado', isEqualTo: empleadoId).snapshots()) {
    final solicitudIds = candidatosSnap.docs.map((doc) => doc['solicitud'] as String).toList();

    if (solicitudIds.isEmpty) {
      yield [];
      continue;
    }

    // Escucha los cambios en las Solicitudes relacionadas (con esos IDs)
    // Firestore whereIn soporta hasta 10 documentos por consulta, hay que tener cuidado si hay más.
    final solicitudesStream = solicitudesRef
        .where(FieldPath.documentId, whereIn: solicitudIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    })
        .where((item) =>
    item['estado'] == 'en progreso' || item['estado'] == 'pendiente'
    )
        .toList()
    );

    // Espera el primer valor y emite (también puedes usar yield* si quieres seguir el stream completo)
    await for (final solicitudes in solicitudesStream) {
      yield solicitudes;
      break; // Sal del bucle para escuchar de nuevo si cambia Candidatos
    }
  }
}


Future<void> aceptarSolicitudEmpleado({
  required String empleadoId,
  required String solicitudId,
}) async {
  final db = FirebaseFirestore.instance;

  final candidatosRef = db.collection('Candidatos');
  final solicitudesRef = db.collection('Solicitudes');
  final usersRef = db.collection('Users');

  final candidatoQuery = await candidatosRef
      .where('empleado', isEqualTo: empleadoId)
      .where('solicitud', isEqualTo: solicitudId)
      .get();
  for (final doc in candidatoQuery.docs) {
    await doc.reference.update({'confirmo': true});
  }

  final solicitudDoc = await solicitudesRef.doc(solicitudId).get();
  final data = solicitudDoc.data()!;
  final int aceptados = data['aceptados'] ?? 0;
  final int cantidad = data['cantidad'] ?? 1;

  if (aceptados < cantidad) {
    await solicitudesRef.doc(solicitudId).update({
      'estado': 'en progreso',
      'aceptados': aceptados + 1,
    });
  }

  final otrosCandidatos = await candidatosRef
      .where('empleado', isEqualTo: empleadoId)
      .where('solicitud', isNotEqualTo: solicitudId)
      .get();
  for (final doc in otrosCandidatos.docs) {
    await doc.reference.delete();
  }

  if (aceptados + 1 >= cantidad) {
    final candidatosDeEstaSolicitud = await candidatosRef
        .where('solicitud', isEqualTo: solicitudId)
        .get();
    for (final doc in candidatosDeEstaSolicitud.docs) {
      if (doc['confirmo'] != true) {
        await doc.reference.delete();
      }
    }
  }

  final userQuery = await usersRef.where('nombre', isEqualTo: empleadoId).get(); // O usa el ID real si lo tienes
  for (final doc in userQuery.docs) {
    await doc.reference.update({'estado': false});
  }
}

Future<List<Map<String, dynamic>>> getUltimoHistorialEmpleado(String empleadoId, {int limit = 100}) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('Historial')
      .where('empleado', isEqualTo: empleadoId)
      .limit(limit)
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}


Future<void> actualizarCalificacionYRangoUsuario(String empleadoId, double calificacion, int rango) async {
  final query = FirebaseFirestore.instance.collection('Users').doc(empleadoId).update({'calificacion': calificacion, 'rango':rango});
}

Future<List<Map<String, dynamic>>> fetchEmpleadosCoincidentes({
  required String profesion,
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) async {
  final rangoMin = calcularRangoMinimo(fechaInicio, fechaFin);

  final snap = await db
      .collection('Users')
      .where('rol', isEqualTo: 'empleado')
      .where('estado', isEqualTo: true)
      .where('profesion', isEqualTo: profesion)
      .where('rango', isGreaterThanOrEqualTo: rangoMin)
      .get();

  return snap.docs.map((d) {
    final data = d.data();
    data['id'] = d.id;
    return data;
  }).toList();
}

Future<List<String>> rankEmpleadosConIA(List<Map<String, dynamic>> empleados, Map<String, dynamic> solicitud) async {
  if (empleados.isEmpty) return [];

  final prompt = GeminiService.buildPrompt(empleados);
  final raw = await GeminiService.generateContent(prompt);

  try {
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    final list = (parsed['candidatos'] as List<dynamic>)
        .map((e) => e['uid'] as String)
        .toList();
    return list;
  } catch (_) {
    // fallback: mismos ids sin IA
    return empleados.map((e) => e['id'] as String).toList();
  }
}

Future<String> addSolicitud({
  required int cantidad,
  required String descripcion,
  required String horario,
  required DateTime entrada,
  required String latitud,
  required String longitud,
  required double monto,
  required String profesion,
  required DateTime salida,
}) async {
  final doc = await db.collection('Solicitudes').add({
    'cantidad': cantidad,
    'descripcion': descripcion,
    'horario': horario,
    'entrada': Timestamp.fromDate(entrada),
    'estado': 'pendiente',
    'latitud': latitud,
    'longitud': longitud,
    'monto': monto,
    'profesion': profesion,
    'salida': Timestamp.fromDate(salida),
  });
  return doc.id;
}

Future<void> initCandidatosParaSolicitud(String solicitudId) async {
  final doc = await db.collection('Solicitudes').doc(solicitudId).get();
  if (!doc.exists) return;
  final data = doc.data()!;
  final profesion = data['profesion'];
  final fechaInicio = (data['entrada'] as Timestamp).toDate();
  final fechaFin = (data['salida'] as Timestamp).toDate();
  final cantidad = data['cantidad'] as int;

  final empleados = await fetchEmpleadosCoincidentes(
    profesion: profesion,
    fechaInicio: fechaInicio,
    fechaFin: fechaFin,
  );

  final ordenados = await rankEmpleadosConIA(empleados, data);

  await doc.reference.update({
    'colaCandidatos': ordenados,
    'aceptados': 0,
    'empleadosAsignados': [],
  });

  final primeros = ordenados.take(cantidad * 3).toList();
  final batch = db.batch();
  for (final empId in primeros) {
    batch.set(db.collection('Candidatos').doc(), {
      'solicitud': solicitudId,
      'empleado': empId,
      'confirmo': false,
    });
  }
  await batch.commit();
}

Future<void> refillCandidatosSiNecesario(String solicitudId) async {
  final solicitudDoc = await db.collection('Solicitudes').doc(solicitudId).get();
  if (!solicitudDoc.exists) return;
  final data = solicitudDoc.data()!;
  final cantidad = data['cantidad'] as int;
  final cola = List<String>.from(data['colaCandidatos'] ?? []);

  final snap = await db
      .collection('Candidatos')
      .where('solicitud', isEqualTo: solicitudId)
      .get();
  final activos = snap.docs.length;
  if (activos >= cantidad * 3) return;

  final currentIds = snap.docs.map((d) => d['empleado'] as String).toSet();
  final toAdd = cola
      .where((id) => !currentIds.contains(id))
      .take(cantidad * 3 - activos)
      .toList();

  final batch = db.batch();
  for (final id in toAdd) {
    batch.set(db.collection('Candidatos').doc(), {
      'solicitud': solicitudId,
      'empleado': id,
      'confirmo': false,
    });
  }
  await batch.commit();
}

Future<void> eliminarCandidatoPorEmpleadoYSolicitud(String empleadoId, String solicitudId) async {
  final q = await db
      .collection('Candidatos')
      .where('empleado', isEqualTo: empleadoId)
      .where('solicitud', isEqualTo: solicitudId)
      .get();
  for (final d in q.docs) await d.reference.delete();
}

Future<void> rejectSolicitudEmpleado({required String empleadoId, required String solicitudId}) async {
  await eliminarCandidatoPorEmpleadoYSolicitud(empleadoId, solicitudId);
  await refillCandidatosSiNecesario(solicitudId);
}

Future<void> cancelSolicitud(String solicitudId) async {
  final solicitudesRef = db.collection('Solicitudes');
  final candidatosRef = db.collection('Candidatos');

  await db.runTransaction((txn) async {
    txn.update(solicitudesRef.doc(solicitudId), {'estado': 'cancelada'});
    final snap = await candidatosRef.where('solicitud', isEqualTo: solicitudId).get();
    for (final d in snap.docs) txn.delete(d.reference);
  });
}

Future<void> acceptSolicitud({required String solicitudId, required String empleadoId}) async {
  final docRef = db.collection('Solicitudes').doc(solicitudId);

  await db.runTransaction((txn) async {
    final snap = await txn.get(docRef);
    if (!snap.exists) throw Exception('Solicitud no encontrada');

    final data = snap.data() as Map<String, dynamic>;
    final cantidad = data['cantidad'] ?? 0;
    final aceptados = data['aceptados'] ?? 0;
    final asignados = List<String>.from(data['empleadosAsignados'] ?? []);

    if (aceptados >= cantidad || asignados.contains(empleadoId)) return;

    asignados.add(empleadoId);

    txn.update(docRef, {
      'aceptados': aceptados + 1,
      'empleadosAsignados': asignados,
      if (aceptados + 1 == cantidad) 'estado': 'en progreso',
    });
  });

  // Mark employee as unavailable
  await db.collection('Users').doc(empleadoId).update({'estado': false});
}


Stream<List<Map<String, dynamic>>> getEmpleadosFiltrados({
  required String profesionBuscada,
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) {
  final int rangoMinimo = calcularRangoMinimo(fechaInicio, fechaFin);

  return db
      .collection('Users')
      .where('rol', isEqualTo: 'empleado')
      .where('estado', isEqualTo: true)          // disponibles
      .where('profesion', isEqualTo: profesionBuscada)
      .where('rango', isGreaterThanOrEqualTo: rangoMinimo)
      .orderBy('rango')                          // (obligatorio tras la comparación)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }).toList());
}

Stream<List<Map<String, dynamic>>> getHistorialEmpleadoRealtime(String empleadoId) {
  return db
      .collection('Historial')
      .where('empleado', isEqualTo: empleadoId)
      // .orderBy('salida', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            data['id'] = d.id;
            return data;
          }).toList());
}