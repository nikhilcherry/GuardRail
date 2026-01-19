import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/resident_provider.dart';

class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  State<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends State<ResidentProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final residentProvider = context.read<ResidentProvider>();
    _nameController = TextEditingController(text: residentProvider.residentName);
    _phoneController = TextEditingController(text: residentProvider.phoneNumber);
    _emailController = TextEditingController(text: residentProvider.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        // In a real app, you would upload this image immediately or upon saving
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _saveProfile() {
    context.read<ResidentProvider>().updateResidentInfo(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          email: _emailController.text,
          profileImage: _imageFile?.path,
        );
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Consumer<ResidentProvider>(
        builder: (context, residentProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : residentProvider.profileImage != null
                                  ? DecorationImage(
                                      image: (residentProvider.profileImage!.startsWith('http')
                                          ? NetworkImage(residentProvider.profileImage!)
                                          : FileImage(File(residentProvider.profileImage!))) as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: (_imageFile == null && residentProvider.profileImage == null)
                            ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant)
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_library, size: 20, color: Colors.black),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Last Login Information
                if (residentProvider.lastLogin != null)
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                     decoration: BoxDecoration(
                       color: Theme.of(context).cardColor.withOpacity(0.5),
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: Text(
                       'Last Login: ${DateFormat('MMM d, yyyy h:mm a').format(residentProvider.lastLogin!)}',
                       style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                     ),
                   ),

                const SizedBox(height: 32),

                // Form Fields
                _ProfileField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                _ProfileField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  maxLength: 20,
                ),
                const SizedBox(height: 16),
                _ProfileField(
                  label: 'Email Address',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 254,
                ),

                const SizedBox(height: 32),

                // Flat Information (Read-only)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RESIDENCE INFORMATION',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.home, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flat ${residentProvider.flatNumber}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tower A, Sunrise Apartments', // Mock data, ideally from Provider
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final int? maxLength;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLength: maxLength,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: enabled ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: enabled ? Theme.of(context).inputDecorationTheme.fillColor : Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: enabled ? (Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.color ?? Theme.of(context).dividerColor) : Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}
