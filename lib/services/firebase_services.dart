import 'package:cloud_firestore/cloud_firestore.dart';

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

Future<void> addSolicitud({
  required int cantidad,
  required String descripcion,
  required String horario,
  required DateTime entrada,
  required String estado,
  required String latitud,
  required String longitud,
  required double monto,
  required String profesion,
  required DateTime salida,
}) async {
  await db.collection('Solicitudes').add({
    "cantidad": cantidad,
    "descripcion": descripcion,
    "horario": horario,
    "entrada": Timestamp.fromDate(entrada),
    "estado": estado,
    "latitud": latitud,
    "longitud": longitud,
    "monto": monto,
    "profesion": profesion,
    "salida": Timestamp.fromDate(salida),
  });
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

Future<void> acceptSolicitud({
  required String solicitudId,
  required String empleadoId,
}) async {
  final docRef = db.collection('Solicitudes').doc(solicitudId);

  await FirebaseFirestore.instance.runTransaction((txn) async {
    final snapshot = await txn.get(docRef);

    if (!snapshot.exists) {
      throw Exception('Solicitud no encontrada');
    }

    final data = snapshot.data() as Map<String, dynamic>;

    final int cantidad = data['cantidad'] ?? 0;
    final int aceptados = data['aceptados'] ?? 0;
    final List<dynamic> asignados = List.from(data['empleadosAsignados'] ?? []);

    // 1. Verifica que aún haya cupos
    if (aceptados >= cantidad) {
      throw Exception('La solicitud ya está completa');
    }

    // 2. Evita que el mismo empleado se apunte dos veces
    if (asignados.contains(empleadoId)) {
      throw Exception('Ya estás asignado a esta solicitud');
    }

    // 3. Aplica los cambios de forma atómica
    txn.update(docRef, {
      'aceptados': FieldValue.increment(1),
      'empleadosAsignados': FieldValue.arrayUnion([empleadoId]),
      // Cierra la solicitud si se cubrió el cupo
      if (aceptados + 1 == cantidad) 'estado': 'en curso'
    });
  });
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
