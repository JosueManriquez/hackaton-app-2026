import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
<<<<<<< HEAD
import 'package:geocoding/geocoding.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
=======
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
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
<<<<<<< HEAD
  
=======

>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
  List<String> _categorias = [];
  final List<String> _prioridades = ['Baja', 'Media', 'Alta'];

  XFile? _imagenSeleccionada;
  Position? _ubicacion;
<<<<<<< HEAD
  String? _direccionAproximada;
=======
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e

  bool _isCargando = true; // Empieza en true para cargar categorías
  final ReportsRepository _repo = ReportsRepository();

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
<<<<<<< HEAD
      final snapshot = await FirebaseFirestore.instance.collection('categorias').get();
      final nombresCategorias = snapshot.docs.map((doc) => doc['nombre'] as String).toList();
      setState(() {
        _categorias = nombresCategorias.isNotEmpty ? nombresCategorias : ['General'];
=======
      final snapshot = await FirebaseFirestore.instance
          .collection('categorias')
          .get();
      final nombresCategorias = snapshot.docs
          .map((doc) => doc['nombre'] as String)
          .toList();
      setState(() {
        _categorias = nombresCategorias.isNotEmpty
            ? nombresCategorias
            : ['General'];
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
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
<<<<<<< HEAD
    final XFile? foto = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
=======
    final XFile? foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
    if (foto != null) {
      setState(() {
        _imagenSeleccionada = foto;
      });
    }
  }

  Future<void> _seleccionarGaleria() async {
    final picker = ImagePicker();
<<<<<<< HEAD
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
=======
    final XFile? foto = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
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
<<<<<<< HEAD
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicios de ubicación desactivados.')));
=======
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicios de ubicación desactivados.')),
      );
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
<<<<<<< HEAD
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso de ubicación denegado.')));
=======
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado.')),
        );
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
<<<<<<< HEAD
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso denegado permanentemente.')));
=======
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso denegado permanentemente.')),
      );
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
      return;
    }

    setState(() {
      _isCargando = true;
    });

    try {
<<<<<<< HEAD
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
=======
      _ubicacion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación obtenida con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error obteniendo GPS: $e')));
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
    } finally {
      setState(() {
        _isCargando = false;
      });
    }
  }

<<<<<<< HEAD

  Future<void> _enviarReporte() async {
    if (_tituloCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa título y descripción')));
=======
  Future<void> _enviarReporte() async {
    if (_tituloCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y descripción')),
      );
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
      return;
    }

    if (_ubicacion == null) {
<<<<<<< HEAD
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Es necesario obtener la ubicación GPS')));
=======
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Es necesario obtener la ubicación GPS')),
      );
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
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
<<<<<<< HEAD
        final fileName = 'reportes/${DateTime.now().millisecondsSinceEpoch}_${_imagenSeleccionada!.name}';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        
=======
        final fileName =
            'reportes/${DateTime.now().millisecondsSinceEpoch}_${_imagenSeleccionada!.name}';
        final ref = FirebaseStorage.instance.ref().child(fileName);

>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
        if (kIsWeb) {
          final bytes = await _imagenSeleccionada!.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          await ref.putFile(File(_imagenSeleccionada!.path));
        }
<<<<<<< HEAD
        
=======

>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
        fotoUrl = await ref.getDownloadURL();
      }

      await _repo.createReport(
        ciudadanoId: user.uid,
        titulo: _tituloCtrl.text,
        descripcion: _descCtrl.text,
        lat: _ubicacion!.latitude,
        lng: _ubicacion!.longitude,
<<<<<<< HEAD
        locationStr: _direccionAproximada ?? 'Lat: ${_ubicacion!.latitude.toStringAsFixed(4)}, Lng: ${_ubicacion!.longitude.toStringAsFixed(4)}',
=======
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
        fotoUrl: fotoUrl,
        categoria: _categoriaSeleccionada ?? 'General',
        prioridad: _prioridadSeleccionada,
      );

      if (mounted) {
<<<<<<< HEAD
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado correctamente')));
=======
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte enviado correctamente')),
        );
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
<<<<<<< HEAD
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
=======
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
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
<<<<<<< HEAD
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Reporte'),
      ),
=======

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Reporte')),
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
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
<<<<<<< HEAD
                    value: _categoriaSeleccionada,
=======
                    initialValue: _categoriaSeleccionada,
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: _categorias.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
<<<<<<< HEAD
                      if (val != null) setState(() => _categoriaSeleccionada = val);
=======
                      if (val != null) {
                        setState(() => _categoriaSeleccionada = val);
                      }
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
<<<<<<< HEAD
                    value: _prioridadSeleccionada,
=======
                    initialValue: _prioridadSeleccionada,
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                    items: _prioridades.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p));
                    }).toList(),
                    onChanged: (val) {
<<<<<<< HEAD
                      if (val != null) setState(() => _prioridadSeleccionada = val);
=======
                      if (val != null) {
                        setState(() => _prioridadSeleccionada = val);
                      }
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
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
<<<<<<< HEAD
                    Text('Imagen capturada: ${_imagenSeleccionada!.name}', textAlign: TextAlign.center, style: TextStyle(color: Colors.green)),
=======
                    Text(
                      'Imagen capturada: ${_imagenSeleccionada!.name}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green),
                    ),
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _obtenerUbicacion,
<<<<<<< HEAD
                    icon: Icon(Icons.gps_fixed, color: _ubicacion != null ? Colors.green : null),
                    label: Text(_ubicacion != null ? 'Ubicación Obtenida' : 'Obtener Ubicación Actual'),
=======
                    icon: Icon(
                      Icons.gps_fixed,
                      color: _ubicacion != null ? Colors.green : null,
                    ),
                    label: Text(
                      _ubicacion != null
                          ? 'Ubicación Obtenida'
                          : 'Obtener Ubicación Actual',
                    ),
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
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
<<<<<<< HEAD
                    child: const Text('Enviar Reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
=======
                    child: const Text(
                      'Enviar Reporte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
>>>>>>> 0bd1db2ae59b711b77950465653c6fac077d978e
                  ),
                ],
              ),
            ),
    );
  }
}
