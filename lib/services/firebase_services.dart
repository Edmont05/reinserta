import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

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

    await docRef.update({
      'estado': 'completada',
      'calificacion': calificacion,
    });

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
}) async {
  final docRef = db.collection('Solicitudes').doc(solicitudId);

  await docRef.update({
    'estado': 'en curso',
  });
}
