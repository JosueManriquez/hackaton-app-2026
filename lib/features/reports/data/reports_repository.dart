import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/report_model.dart';

class ReportsRepository {
  final FirebaseFirestore _firestore;

  ReportsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Obtener todos los reportes (para el mapa)
  Stream<List<ReportModel>> getAllReportsStream() {
    return _firestore
        .collection('reportes')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> createReport({
    required String ciudadanoId,
    required String titulo,
    required String descripcion,
    required double lat,
    required double lng,
<<<<<<< HEAD
    required String locationStr,
=======
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
    required String fotoUrl,
    required String categoria,
    required String prioridad,
  }) async {
<<<<<<< HEAD
    final counterRef = _firestore.collection('sistema').doc('contadores');
    
    final int newSequence = await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);
      int currentCount = 0;
      if (snapshot.exists && snapshot.data() != null && snapshot.data()!.containsKey('totalReportes')) {
        currentCount = snapshot.get('totalReportes') as int;
      }
      final nextCount = currentCount + 1;
      transaction.set(counterRef, {'totalReportes': nextCount}, SetOptions(merge: true));
      return nextCount;
    });
    
    final String ticketIdStr = 'REP-${newSequence.toString().padLeft(5, '0')}';

    await _firestore.collection('reportes').add({
      'ticketId': ticketIdStr,
=======
    await _firestore.collection('reportes').add({
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
      'ciudadanoId': ciudadanoId,
      'titulo': titulo,
      'descripcion': descripcion,
      'locationCoords': [lat, lng],
<<<<<<< HEAD
      'locationStr': locationStr,
=======
      'locationStr': 'Lat: $lat, Lng: $lng',
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
      'fotoUrl': fotoUrl,
      'estado': 'Nuevo',
      'fecha': FieldValue.serverTimestamp(),
      'categoria': categoria,
      'prioridad': prioridad,
<<<<<<< HEAD
      'historial': [
        {
          'accion': 'Reporte Creado',
          'actor': 'Ciudadano',
          'fecha': Timestamp.now(),
        }
      ],
=======
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
    });
  }
}
