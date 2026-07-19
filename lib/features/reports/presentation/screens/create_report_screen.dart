import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/reports_repository.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _categoriaSeleccionada;
  String _prioridadSeleccionada = 'Media';
  
  List<String> _categorias = [];
  final List<String> _prioridades = ['Baja', 'Media', 'Alta'];

  XFile? _imagenSeleccionada;
  Position? _ubicacion;
  String? _direccionAproximada;

  bool _isCargando = true; // Empieza en true para cargar categorías
  final ReportsRepository _repo = ReportsRepository();

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categorias').get();
      final nombresCategorias = snapshot.docs.map((doc) => doc['nombre'] as String).toList();
      setState(() {
        _categorias = nombresCategorias.isNotEmpty ? nombresCategorias : ['General'];
        _categoriaSeleccionada = _categorias.first;
        _isCargando = false;
      });
    } catch (e) {
      setState(() {
        _categorias = ['General'];
        _categoriaSeleccionada = 'General';
        _isCargando = false;
      });
    }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    // imageQuality: 50 aplica la compresión nativa requerida por el usuario
    final XFile? foto = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (foto != null) {
      setState(() {
        _imagenSeleccionada = foto;
      });
    }
  }

  Future<void> _seleccionarGaleria() async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (foto != null) {
      setState(() {
        _imagenSeleccionada = foto;
      });
    }
  }

  Future<void> _obtenerUbicacion() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicios de ubicación desactivados.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso de ubicación denegado.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso denegado permanentemente.')));
      return;
    }

    setState(() {
      _isCargando = true;
    });

    try {
      _ubicacion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      // Intentar obtener la dirección de las coordenadas
      try {
        final Geocoding geocoding = Geocoding();
        List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(_ubicacion!.latitude, _ubicacion!.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          final calle = place.street ?? place.name ?? place.subLocality ?? '';
          final ciudad = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '';
          if (calle.isNotEmpty && ciudad.isNotEmpty) {
            _direccionAproximada = '$calle, $ciudad';
          } else {
            _direccionAproximada = '${place.name ?? ''}, ${place.country ?? ''}';
          }
        }
      } catch (e) {
        // Si falla la geocodificación inversa, nos quedamos con lat/lng
        _direccionAproximada = null;
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ubicación obtenida con éxito')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error obteniendo GPS: $e')));
    } finally {
      setState(() {
        _isCargando = false;
      });
    }
  }


  Future<void> _enviarReporte() async {
    if (_tituloCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa título y descripción')));
      return;
    }

    if (_ubicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Es necesario obtener la ubicación GPS')));
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).userData;
    if (user == null) return;

    setState(() {
      _isCargando = true;
    });

    try {
      String fotoUrl = '';

      // Subir imagen a Firebase Storage si hay una
      if (_imagenSeleccionada != null) {
        final fileName = 'reportes/${DateTime.now().millisecondsSinceEpoch}_${_imagenSeleccionada!.name}';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        
        if (kIsWeb) {
          final bytes = await _imagenSeleccionada!.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          await ref.putFile(File(_imagenSeleccionada!.path));
        }
        
        fotoUrl = await ref.getDownloadURL();
      }

      await _repo.createReport(
        ciudadanoId: user.uid,
        titulo: _tituloCtrl.text,
        descripcion: _descCtrl.text,
        lat: _ubicacion!.latitude,
        lng: _ubicacion!.longitude,
        locationStr: _direccionAproximada ?? 'Lat: ${_ubicacion!.latitude.toStringAsFixed(4)}, Lng: ${_ubicacion!.longitude.toStringAsFixed(4)}',
        fotoUrl: fotoUrl,
        categoria: _categoriaSeleccionada ?? 'General',
        prioridad: _prioridadSeleccionada,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado correctamente')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Reporte'),
      ),
      body: _isCargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título corto del problema',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _categoriaSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: _categorias.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _categoriaSeleccionada = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _prioridadSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                    items: _prioridades.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _prioridadSeleccionada = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descripción detallada',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _tomarFoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Cámara'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _seleccionarGaleria,
                        icon: const Icon(Icons.image),
                        label: const Text('Galería'),
                      ),
                    ],
                  ),
                  if (_imagenSeleccionada != null) ...[
                    const SizedBox(height: 16),
                    Text('Imagen capturada: ${_imagenSeleccionada!.name}', textAlign: TextAlign.center, style: TextStyle(color: Colors.green)),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _obtenerUbicacion,
                    icon: Icon(Icons.gps_fixed, color: _ubicacion != null ? Colors.green : null),
                    label: Text(_ubicacion != null ? 'Ubicación Obtenida' : 'Obtener Ubicación Actual'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _enviarReporte,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Enviar Reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }
}
