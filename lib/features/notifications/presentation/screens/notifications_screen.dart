import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _marcarComoLeida(String uid, String notificacionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('notificaciones')
          .doc(notificacionId)
          .update({'leida': true});
    } catch (e) {
      debugPrint('Error al marcar notificación como leída: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).userData;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notificaciones')),
        body: const Center(child: Text('Debes iniciar sesión')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('notificaciones')
            // .orderBy('fecha', descending: true) // Evitamos el orderBy para no requerir índice compuesto
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No tienes notificaciones.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Ordenamos localmente por fecha
          final notificaciones = snapshot.data!.docs.toList();
          notificaciones.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            
            final fechaA = dataA['fecha'] as Timestamp?;
            final fechaB = dataB['fecha'] as Timestamp?;
            
            if (fechaA == null || fechaB == null) return 0;
            return fechaB.compareTo(fechaA); // Descendente
          });

          return ListView.builder(
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final doc = notificaciones[index];
              final data = doc.data() as Map<String, dynamic>;
              
              final titulo = data['titulo'] ?? 'Notificación';
              final cuerpo = data['cuerpo'] ?? '';
              final leida = data['leida'] ?? false;
              final fechaTs = data['fecha'] as Timestamp?;
              final fecha = fechaTs != null ? fechaTs.toDate() : DateTime.now();

              return Card(
                elevation: leida ? 0 : 2,
                color: leida ? Colors.transparent : Colors.blue.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    leida ? Icons.notifications_none : Icons.notifications_active,
                    color: leida ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: leida ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cuerpo.isNotEmpty) ...[
                        Text(cuerpo),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (!leida) {
                      _marcarComoLeida(user.uid, doc.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
