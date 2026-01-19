import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/visitor.dart';
import '../providers/guard_provider.dart';
import '../screens/guard/visitor_status_screen.dart';

class VisitorDialog extends StatefulWidget {
  final Visitor? entry;
  const VisitorDialog({Key? key, this.entry}) : super(key: key);

  @override
  State<VisitorDialog> createState() => _VisitorDialogState();
}

class _VisitorDialogState extends State<VisitorDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController flatCtrl;
  late TextEditingController vehicleNumberCtrl;
  String purpose = 'guest';
  String vehicleType = 'None';
  bool loading = false;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Track if the image has been modified during this session
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.entry?.name ?? '');
    flatCtrl = TextEditingController(text: widget.entry?.flatNumber ?? '');
    vehicleNumberCtrl = TextEditingController(text: widget.entry?.vehicleNumber ?? '');
    purpose = widget.entry?.purpose ?? 'guest';
    vehicleType = widget.entry?.vehicleType ?? 'None';
    if (widget.entry?.photoPath != null) {
      _imageFile = XFile(widget.entry!.photoPath!);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    flatCtrl.dispose();
    vehicleNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _imageFile = photo;
          _imageChanged = true;
        });
      }
    } catch (e) {
      // Handle camera error or permission denial gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open camera: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = widget.entry != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(editing ? 'Edit Visitor' : 'Register Visitor',
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),

              // Photo Capture Area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.dividerColor),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(File(_imageFile!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? Icon(Icons.camera_alt,
                          size: 40, color: theme.disabledColor)
                      : null,
                ),
              ),
              if (_imageFile == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Tap to take photo',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.disabledColor)),
                ),

              const SizedBox(height: 16),

              TextField(
                controller: flatCtrl,
                textInputAction: TextInputAction.next,
                maxLength: 10, // SECURITY: Prevent large input DoS
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                decoration: const InputDecoration(labelText: 'Flat Number'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: nameCtrl,
                textInputAction: TextInputAction.next,
                maxLength: 100, // SECURITY: Prevent large input DoS
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                decoration: const InputDecoration(labelText: 'Visitor Name'),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: purpose,
                items: const [
                  DropdownMenuItem(value: 'guest', child: Text('Guest')),
                  DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                  DropdownMenuItem(value: 'service', child: Text('Service')),
                ],
                onChanged: (v) => setState(() => purpose = v!),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: vehicleType,
                decoration: const InputDecoration(labelText: 'Vehicle Type'),
                items: const [
                  DropdownMenuItem(value: 'None', child: Text('None')),
                  DropdownMenuItem(value: 'Car', child: Text('Car')),
                  DropdownMenuItem(value: 'Bike', child: Text('Bike')),
                  DropdownMenuItem(value: 'Auto', child: Text('Auto')),
                  DropdownMenuItem(value: 'Cab', child: Text('Cab')),
                ],
                onChanged: (v) => setState(() => vehicleType = v!),
              ),

              if (vehicleType != 'None') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: vehicleNumberCtrl,
                  maxLength: 20, // SECURITY: Prevent large input DoS
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  decoration: const InputDecoration(labelText: 'Vehicle Number'),
                ),
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        setState(() => loading = true);

                        try {
                          String? savedPhotoPath;

                          if (_imageFile != null) {
                             if (_imageChanged) {
                               // Only save if changed (new photo)
                               final directory = await getApplicationDocumentsDirectory();
                               final fileName = 'visitor_${DateTime.now().millisecondsSinceEpoch}.jpg';
                               final savedImage = await File(_imageFile!.path).copy(path.join(directory.path, fileName));
                               savedPhotoPath = savedImage.path;
                             } else {
                               // Keep existing path
                               savedPhotoPath = widget.entry?.photoPath;
                             }
                          }

                          final guard = context.read<GuardProvider>();
                          Visitor? entry;
                          if (editing) {
                            await guard.updateVisitorEntry(
                              id: widget.entry!.id,
                              name: nameCtrl.text,
                              flatNumber: flatCtrl.text,
                              purpose: purpose,
                              photoPath: savedPhotoPath,
                              vehicleNumber: vehicleType != 'None' ? vehicleNumberCtrl.text : null,
                              vehicleType: vehicleType != 'None' ? vehicleType : null,
                            );
                            entry = widget.entry;
                          } else {
                            entry = await guard.registerNewVisitor(
                              name: nameCtrl.text,
                              flatNumber: flatCtrl.text,
                              purpose: purpose,
                              photoPath: savedPhotoPath,
                              vehicleNumber: vehicleType != 'None' ? vehicleNumberCtrl.text : null,
                              vehicleType: vehicleType != 'None' ? vehicleType : null,
                            );
                          }

                          if (context.mounted) {
                            Navigator.pop(context); // Close dialog
                            if (!editing && entry != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VisitorStatusScreen(entryId: entry!.id),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => loading = false);
                        }
                      },
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(editing ? 'Save' : 'Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
