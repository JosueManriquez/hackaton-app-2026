import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reports/data/reports_repository.dart';
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
      appBar: AppBar(
        title: const Text('Mis Reportes'),
      ),
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
                child: Text('Falta crear el índice en Firestore o hay un error de conexión.\n\nDetalle: ${snapshot.error}', textAlign: TextAlign.center),
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

          final reportes = snapshot.data!.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
          reportes.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final reporte = reportes[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showReportDetails(context, reporte),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (reporte.fotoUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            reporte.fotoUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reporte.titulo,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      if (reporte.ticketId.isNotEmpty)
                                        Text(
                                          reporte.ticketId,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getColorForEstado(reporte.estado).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getColorForEstado(reporte.estado)),
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
                              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showReportDetails(BuildContext context, ReportModel reporte) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reporte.titulo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (reporte.ticketId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(reporte.ticketId, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getColorForEstado(reporte.estado).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getColorForEstado(reporte.estado)),
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
              const SizedBox(height: 16),
              if (reporte.fotoUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    reporte.fotoUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(reporte.descripcion),
              const SizedBox(height: 24),
              if (reporte.estado.toLowerCase() == 'resuelto')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance.collection('reportes').doc(reporte.id).update({
                          'estado': 'Cerrado',
                          'historial': FieldValue.arrayUnion([
                            {
                              'accion': 'Cambio de estado a Cerrado',
                              'actor': 'Ciudadano',
                              'fecha': Timestamp.now(),
                            }
                          ])
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte marcado como cerrado')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Marcar como Cerrado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Color _getColorForEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'nuevo': return Colors.blue;
      case 'asignado': return Colors.orange;
      case 'en progreso': return Colors.purple;
      case 'resuelto': return Colors.green;
      default: return Colors.grey;
    }
  }
}
