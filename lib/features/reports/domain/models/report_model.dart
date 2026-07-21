import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String ticketId;
  final String ciudadanoId;
  final String titulo;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String fotoUrl;
  final String estado; // Nuevo, En Progreso, Resuelto, etc.
  final DateTime fechaRegistro;
  final String categoria;
  final String prioridad;
  final String prioridadIA;
  final String justificacionIA;

  ReportModel({
    required this.id,
    required this.ticketId,
    required this.ciudadanoId,
    required this.titulo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.fotoUrl,
    required this.estado,
    required this.fechaRegistro,
    required this.categoria,
    required this.prioridad,
    required this.prioridadIA,
    required this.justificacionIA,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    print("REPORTE DATA: $data");
    
    // Manejar diferentes formatos de fecha (Timestamp de Firestore o String)
    DateTime parsedDate = DateTime.now();
    if (data['fecha'] is Timestamp) {
      parsedDate = (data['fecha'] as Timestamp).toDate();
    } else if (data['fecha'] is String) {
      parsedDate = DateTime.tryParse(data['fecha']) ?? DateTime.now();
    }

    return ReportModel(
      id: doc.id,
      ticketId: data['ticketId'] ?? '',
      ciudadanoId: data['ciudadanoId'] ?? '',
      titulo: data['titulo'] ?? 'Sin título',
      descripcion: data['descripcion'] ?? '',
      latitud: (data['locationCoords'] != null && data['locationCoords'].length > 0) ? (data['locationCoords'][0] as num).toDouble() : 0.0,
      longitud: (data['locationCoords'] != null && data['locationCoords'].length > 1) ? (data['locationCoords'][1] as num).toDouble() : 0.0,
      fotoUrl: data['fotoUrl'] ?? '',
      estado: data['estado'] ?? 'Nuevo',
      fechaRegistro: parsedDate,
      categoria: data['categoria'] ?? 'General',
      prioridad: data['prioridad'] ?? 'Media',
      prioridadIA: data['prioridadIA'] ?? '',
      justificacionIA: data['justificacionIA'] ?? '',
    );
  }
}
