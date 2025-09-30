import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class StudentData {
  String name;
  String id;
  String program;
  String department;
  String location;
  String? imagePath; // For mobile: file path
  Uint8List? imageBytes; // For web: image bytes

  StudentData({
    required this.name,
    required this.id,
    required this.program,
    required this.department,
    required this.location,
    this.imagePath, // Optional image path
    this.imageBytes, // Optional image bytes
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StudentData defaultData = StudentData(
    name: 'Muntasir Hossain',
    id: '210041265',
    program: 'BSc in CSE',
    department: 'CSE',
    location: 'Bangladesh',
    imagePath: null, // No custom image by default
    imageBytes: null,
  );

  StudentData? currentData;
  bool showForm = true;

  @override
  void initState() {
    super.initState();
    currentData = defaultData;
  }

  void navigateToCard(StudentData data) {
    setState(() {
      currentData = data;
      showForm = false;
    });
  }

  void navigateToForm() {
    setState(() {
      showForm = true;
    });
  }

  void cancelForm() {
    setState(() {
      currentData = defaultData;
      showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: showForm
          ? FormPage(
              onSubmit: navigateToCard,
              onCancel: cancelForm,
              currentData: currentData!,
            )
          : IDCardPage(studentData: currentData!, onEdit: navigateToForm),
    );
  }
}

// Form Page
class FormPage extends StatefulWidget {
  final Function(StudentData) onSubmit;
  final Function() onCancel;
  final StudentData currentData;

  FormPage({
    required this.onSubmit,
    required this.onCancel,
    required this.currentData,
  });

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController idController;
  late TextEditingController programController;
  late TextEditingController departmentController;
  late TextEditingController locationController;

  // Image picker instance and selected image path
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes; // For web platform

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentData.name);
    idController = TextEditingController(text: widget.currentData.id);
    programController = TextEditingController(text: widget.currentData.program);
    departmentController = TextEditingController(
      text: widget.currentData.department,
    );
    locationController = TextEditingController(
      text: widget.currentData.location,
    );
    // Initialize with existing image path/bytes if available
    _selectedImagePath = widget.currentData.imagePath;
    _selectedImageBytes = widget.currentData.imageBytes;
  }

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web: read image as bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImagePath = null;
          });
        } else {
          // For mobile: use file path
          setState(() {
            _selectedImagePath = image.path;
            _selectedImageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // Function to pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web: read image as bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImagePath = null;
          });
        } else {
          // For mobile: use file path
          setState(() {
            _selectedImagePath = image.path;
            _selectedImageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
    }
  }

  // Function to show image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF1B4332)),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF1B4332)),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to remove selected image
  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
      _selectedImageBytes = null;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    programController.dispose();
    departmentController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // Helper method to build image preview
  Widget _buildImagePreview() {
    if (kIsWeb && _selectedImageBytes != null) {
      // Web: display from bytes
      return ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
      );
    } else if (!kIsWeb && _selectedImagePath != null) {
      // Mobile: display from file
      return ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
      );
    } else {
      // No image selected
      return Icon(Icons.person, size: 80, color: Colors.grey[400]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Student Information Form'),
        backgroundColor: Color(0xFF1B4332),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  'Enter Student Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4332),
                  ),
                ),
                SizedBox(height: 30),

                // Image Picker Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF1B4332),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildImagePreview(),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: Icon(Icons.add_a_photo, size: 20),
                            label: Text('Pick Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1B4332),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          if (_selectedImagePath != null ||
                              _selectedImageBytes != null) ...[
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _removeImage,
                              icon: Icon(Icons.delete, size: 20),
                              label: Text('Remove'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Name Field
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Student Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter student name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // ID Field
                TextFormField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: 'Student ID',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter student ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Program Field
                TextFormField(
                  controller: programController,
                  decoration: InputDecoration(
                    labelText: 'Program',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter program';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Department Field
                TextFormField(
                  controller: departmentController,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter department';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Location Field
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            StudentData newData = StudentData(
                              name: nameController.text,
                              id: idController.text,
                              program: programController.text,
                              department: departmentController.text,
                              location: locationController.text,
                              imagePath:
                                  _selectedImagePath, // Include image path for mobile
                              imageBytes:
                                  _selectedImageBytes, // Include image bytes for web
                            );
                            widget.onSubmit(newData);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1B4332),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ID Card Page
class IDCardPage extends StatefulWidget {
  final StudentData studentData;
  final Function() onEdit;

  IDCardPage({required this.studentData, required this.onEdit});

  @override
  _IDCardPageState createState() => _IDCardPageState();
}

class _IDCardPageState extends State<IDCardPage> {
  Color cardHeaderFooterColor = Color(0xFF1B4332);
  Color cardContentColor = Colors.white;
  final Random random = Random();
  String currentFont = 'Roboto';

  List<String> availableFonts = [
    'Roboto',
    'Lato',
    'Oswald',
    'Montserrat',
    'Raleway',
  ];

  Color generateRandomColor() {
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  bool areColorsSimilar(Color color1, Color color2) {
    int redDiff = (color1.red - color2.red).abs();
    int greenDiff = (color1.green - color2.green).abs();
    int blueDiff = (color1.blue - color2.blue).abs();
    return (redDiff + greenDiff + blueDiff) < 100;
  }

  Color getInverseColor(Color color) {
    return Color.fromARGB(
      255,
      255 - color.red,
      255 - color.green,
      255 - color.blue,
    );
  }

  void changeColors() {
    setState(() {
      Color newHeaderFooterColor = generateRandomColor();
      Color newContentColor;

      do {
        newContentColor = generateRandomColor();
      } while (areColorsSimilar(newHeaderFooterColor, newContentColor));

      cardHeaderFooterColor = newHeaderFooterColor;
      cardContentColor = newContentColor;
    });
  }

  void changeFontStyle() {
    setState(() {
      String newFont;
      do {
        newFont = availableFonts[random.nextInt(availableFonts.length)];
      } while (newFont == currentFont);
      currentFont = newFont;
    });
  }

  TextStyle getTextStyle({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.getFont(
      currentFont,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color headerFooterTextColor = cardHeaderFooterColor == Color(0xFF1B4332)
        ? Colors.white
        : getInverseColor(cardHeaderFooterColor);
    Color contentTextColor = cardContentColor == Colors.white
        ? Colors.black
        : getInverseColor(cardContentColor);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Student ID Card'),
        backgroundColor: Color.fromARGB(255, 253, 255, 254),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: widget.onEdit,
            tooltip: 'Edit Form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 340,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: cardHeaderFooterColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/iut-logo.jpeg',
                            height: 65,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                            textAlign: TextAlign.center,
                            style: getTextStyle(
                              fontSize: 15,
                              color: headerFooterTextColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 20),
                      color: cardContentColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: contentTextColor,
                                  width: 3,
                                ),
                              ),
                              // Display custom image if available, otherwise use default
                              child: _buildProfileImage(),
                            ),
                          ),
                          SizedBox(height: 20),

                          Row(
                            children: [
                              Icon(
                                Icons.vpn_key,
                                size: 18,
                                color: contentTextColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Student ID',
                                style: getTextStyle(
                                  fontSize: 14,
                                  color: contentTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: cardHeaderFooterColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: headerFooterTextColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  widget.studentData.id,
                                  style: getTextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: headerFooterTextColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),

                          _buildInfoRow(
                            Icons.person,
                            'Student Name',
                            widget.studentData.name,
                            contentTextColor,
                          ),
                          SizedBox(height: 14),
                          _buildInfoRow(
                            Icons.school,
                            'Program',
                            widget.studentData.program,
                            contentTextColor,
                          ),
                          SizedBox(height: 14),
                          _buildInfoRow(
                            Icons.business,
                            'Department',
                            widget.studentData.department,
                            contentTextColor,
                          ),
                          SizedBox(height: 14),
                          _buildInfoRow(
                            Icons.location_on,
                            '',
                            widget.studentData.location,
                            contentTextColor,
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: cardHeaderFooterColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'A subsidiary organ of OIC',
                          style: getTextStyle(
                            fontSize: 12,
                            color: headerFooterTextColor.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: changeFontStyle,
            backgroundColor: Colors.blue[800],
            heroTag: 'fontButton',
            child: Icon(Icons.font_download, color: Colors.white),
            tooltip: 'Change Font',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: changeColors,
            backgroundColor: Color(0xFF1B4332),
            heroTag: 'colorButton',
            child: Icon(Icons.color_lens, color: Colors.white),
            tooltip: 'Change Colors',
          ),
        ],
      ),
    );
  }

  // Helper method to build profile image
  Widget _buildProfileImage() {
    if (kIsWeb && widget.studentData.imageBytes != null) {
      // Web: display from bytes
      return Image.memory(widget.studentData.imageBytes!, fit: BoxFit.cover);
    } else if (!kIsWeb && widget.studentData.imagePath != null) {
      // Mobile: display from file
      return Image.file(File(widget.studentData.imagePath!), fit: BoxFit.cover);
    } else {
      // Default image
      return Image.asset('assets/images/profile image.jpg', fit: BoxFit.cover);
    }
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 2),
          child: Icon(icon, size: 20, color: textColor),
        ),
        SizedBox(width: 10),
        if (label.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: getTextStyle(
                  fontSize: 13,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: getTextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          )
        else
          Text(
            value,
            style: getTextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
      ],
    );
  }
}
