// sos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../bloc/sos/sos_bloc.dart';
import '../../models/user.dart';
import '../../widgets/sos_button.dart';

class SosScreen extends StatefulWidget {
  final User currentUser;

  const SosScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _descriptionController = TextEditingController();
  
  String _selectedType = 'Medical';
  final List<String> _emergencyTypes = [
    'Medical',
    'Fire',
    'Flood',
    'Earthquake',
    'Security',
    'Other',
  ];
  
  List<File> _selectedImages = [];
  bool _isSubmitting = false;
  bool _isConfirming = false;
  
  // Pick images from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  // Remove an image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  
  // Show confirmation dialog
  void _showConfirmationDialog() {
    setState(() {
      _isConfirming = true;
    });
    
    // Check form validity
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isConfirming = false;
      });
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm SOS Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to send an SOS request? This will alert emergency responders.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Type: $_selectedType'),
            const SizedBox(height: 8),
            Text('Description: ${_descriptionController.text}'),
            const SizedBox(height: 8),
            Text('Photos: ${_selectedImages.length}'),
            const SizedBox(height: 16),
            const Text(
              'Your location will be shared with emergency responders.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isConfirming = false;
              });
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: _submitSosRequest,
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }
  
  // Submit SOS request
  void _submitSosRequest() {
    setState(() {
      _isSubmitting = true;
    });
    
    Navigator.of(context).pop(); // Close the confirmation dialog
    
    // The photo upload would normally happen here
    // For this hackathon demo, we'll just pretend it worked instantly
    final List<String> photoUrls = _selectedImages.map((file) => 'dummy_url').toList();
    
    // Dispatch SOS event
    context.read<SosBloc>().add(SosSendRequest(
      userId: widget.currentUser.id,
      userName: widget.currentUser.name,
      type: _selectedType,
      description: _descriptionController.text,
      photoUrls: photoUrls,
    ));
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SosBloc, SosState>(
        listener: (context, state) {
          if (state is SosSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SOS request sent successfully'),
                backgroundColor: Colors.green,
              ),
            );
            
            setState(() {
              _isSubmitting = false;
              _isConfirming = false;
              _descriptionController.clear();
              _selectedImages = [];
            });
          } else if (state is SosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
            
            setState(() {
              _isSubmitting = false;
              _isConfirming = false;
            });
          }
        },
        builder: (context, state) {
          if (state is SosLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sending SOS request...'),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SOS button
                  Center(
                    child: SosButton(
                      onPressed: () {
                        if (!_isConfirming && !_isSubmitting) {
                          _showConfirmationDialog();
                        }
                      },
                      size: 150,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Instructions
                  const Text(
                    'Tap the SOS button 3 times to trigger the emergency form.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Divider
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),
                  
                  // Emergency details form
                  const Text(
                    'Emergency Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Emergency type dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Emergency Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.warning_amber),
                    ),
                    value: _selectedType,
                    items: _emergencyTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an emergency type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Briefly describe your emergency',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.length < 10) {
                        return 'Description should be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Photo buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Upload Photo'),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Selected images
                  if (_selectedImages.isNotEmpty) ...[
                    const Text(
                      'Selected Photos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Submit button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isSubmitting || _isConfirming
                        ? null
                        : _showConfirmationDialog,
                    child: const Text(
                      'SEND SOS REQUEST',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}