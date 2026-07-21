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
    required String locationStr,
    required String fotoUrl,
    required String categoria,
    required String prioridad,
    required String prioridadIA,
    required String justificacionIA,
  }) async {
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
      'ciudadanoId': ciudadanoId,
      'titulo': titulo,
      'descripcion': descripcion,
      'locationCoords': [lat, lng],
      'locationStr': locationStr,
      'fotoUrl': fotoUrl,
      'estado': 'Nuevo',
      'fecha': FieldValue.serverTimestamp(),
      'categoria': categoria,
      'prioridad': prioridad,
      'prioridadIA': prioridadIA,
      'justificacionIA': justificacionIA,
      'historial': [
        {
          'accion': 'Reporte Creado',
          'actor': 'Ciudadano',
          'fecha': Timestamp.now(),
        }
      ],
    });
  }
}
