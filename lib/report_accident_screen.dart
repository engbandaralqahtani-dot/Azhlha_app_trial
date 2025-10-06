import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class ReportAccidentScreen extends StatefulWidget {
  const ReportAccidentScreen({super.key, this.position});
  final Position? position;

  @override
  State<ReportAccidentScreen> createState() => _ReportAccidentScreenState();
}

class _ReportAccidentScreenState extends State<ReportAccidentScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  String? _locationError;
  List<File> _images = [];
  bool _needAmbulance = false;
  String? _accidentType;
  final List<String> _accidentTypes = [
    'تصادم',
    'انقلاب',
    'دهس',
    'حريق',
    'أخرى'
  ];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.position;
    if (_currentPosition == null) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'خدمة الموقع غير مفعلة';
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'تم رفض إذن الموقع';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'إذن الموقع مرفوض بشكل دائم';
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _locationError = null;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      setState(() {
        _locationError = 'تعذر الحصول على الموقع';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _images.add(File(picked.path));
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController?.moveCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    setState(() {
      _sending = true;
    });
    // TODO: إرسال البيانات إلى Firebase أو الخادم
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _sending = false;
    });
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم إرسال البلاغ'),
          content: const Text('تم إرسال بلاغك بنجاح وسيتم التواصل معك قريباً.'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إبلاغ عن حادث'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 220,
                child: _currentPosition != null
                    ? GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude),
                          zoom: 16,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('current'),
                            position: LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      )
                    : Center(
                        child: _locationError != null
                            ? Text(_locationError!,
                                style: const TextStyle(color: Colors.red))
                            : const CircularProgressIndicator(),
                      ),
              ),
              const SizedBox(height: 12),
              if (_currentPosition != null)
                Text(
                  'موقعك الحالي: ${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('صور الحادث:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.blue),
                    onPressed: _pickImage,
                  ),
                  ..._images.map((img) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Image.file(img,
                            width: 50, height: 50, fit: BoxFit.cover),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('هل تحتاج إلى إسعاف؟',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('نعم'),
                    selected: _needAmbulance,
                    onSelected: (v) => setState(() => _needAmbulance = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('لا'),
                    selected: !_needAmbulance,
                    onSelected: (v) => setState(() => _needAmbulance = false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _accidentType,
                items: _accidentTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => _accidentType = val),
                decoration: const InputDecoration(
                  labelText: 'نوع الحادث',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _sending ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('تأكيد البلاغ',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
