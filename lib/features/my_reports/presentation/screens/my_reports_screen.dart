import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reports/domain/models/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).userData;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Reportes')),
        body: const Center(child: Text('Debes iniciar sesión')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reportes')),
      body: StreamBuilder<QuerySnapshot>(
        // Consultamos directamente usando el ID del ciudadano
        stream: FirebaseFirestore.instance
            .collection('reportes')
            .where('ciudadanoId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // El error suele suceder si falta un índice compuesto en Firestore
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Falta crear el índice en Firestore o hay un error de conexión.\n\nDetalle: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No has creado ningún reporte aún.\n\n¡Ve al mapa y presiona Reportar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final reportes = snapshot.data!.docs
              .map((doc) => ReportModel.fromFirestore(doc))
              .toList();
          reportes.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final reporte = reportes[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (reporte.fotoUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          reporte.fotoUrl,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 150,
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  reporte.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getColorForEstado(
                                    reporte.estado,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getColorForEstado(reporte.estado),
                                  ),
                                ),
                                child: Text(
                                  reporte.estado.toUpperCase(),
                                  style: TextStyle(
                                    color: _getColorForEstado(reporte.estado),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            reporte.descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Categoría: ${reporte.categoria}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getColorForEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'nuevo':
        return Colors.blue;
      case 'asignado':
        return Colors.orange;
      case 'en progreso':
        return Colors.purple;
      case 'resuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
