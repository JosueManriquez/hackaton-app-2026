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
    required String fotoUrl,
    required String categoria,
    required String prioridad,
  }) async {
    await _firestore.collection('reportes').add({
      'ciudadanoId': ciudadanoId,
      'titulo': titulo,
      'descripcion': descripcion,
      'locationCoords': [lat, lng],
      'locationStr': 'Lat: $lat, Lng: $lng',
      'fotoUrl': fotoUrl,
      'estado': 'Nuevo',
      'fecha': FieldValue.serverTimestamp(),
      'categoria': categoria,
      'prioridad': prioridad,
    });
  }
}
