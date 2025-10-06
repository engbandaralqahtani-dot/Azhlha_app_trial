import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/accident_report.dart';
import '../providers/accident_provider.dart';

class AccidentReportSheet extends StatefulWidget {
  const AccidentReportSheet({super.key});

  @override
  State<AccidentReportSheet> createState() => _AccidentReportSheetState();
}

class _AccidentReportSheetState extends State<AccidentReportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  LatLng? _selectedLocation;
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  late GoogleMapController _mapController;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: controller,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildLocationPicker(),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Text(
          'بلاغ حادث جديد',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'وصف الحادث',
        hintText: 'اكتب وصفاً مختصراً للحادث...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال وصف للحادث';
        }
        return null;
      },
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(18.2163, 42.5047), // أبها
          zoom: 12,
        ),
        onMapCreated: (controller) => _mapController = controller,
        onTap: (location) {
          setState(() => _selectedLocation = location);
        },
        markers: _selectedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('accident'),
                  position: _selectedLocation!,
                ),
              },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.camera_alt),
          label: const Text('إضافة صور'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        if (_images.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_images[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => _removeImage(index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitting ? null : _submitReport,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
      ),
      child: _submitting
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('إرسال البلاغ'),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() => _images.addAll(images));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تحديد موقع الحادث قبل إرسال البلاغ'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل الدخول لإرسال البلاغ'),
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final provider = context.read<AccidentReportProvider>();
      final reportId = FirebaseFirestore.instance.collection('accidents').doc().id;
      final now = DateTime.now();

      final report = AccidentReport(
        id: reportId,
        userId: user.uid,
        description: _descriptionController.text.trim(),
        timestamp: now,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        images: const [],
        status: 'pending',
        towTruckId: null,
        repairShopId: null,
        statusTimeline: {
          'reported': now,
        },
      );

      await provider.createReport(
        report,
        _images.map((image) => image.path).toList(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال البلاغ بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال البلاغ: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}
