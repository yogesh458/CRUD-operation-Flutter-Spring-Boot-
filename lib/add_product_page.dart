import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  Uint8List? _imageBytes;
  String? _fileName;
  String? _filePath; // used in mobile

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Use FilePicker for Web
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _imageBytes = result.files.single.bytes;
          _fileName = result.files.single.name;
        });
      }
    } else {
      // Use ImagePicker for Android/iOS
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _filePath = image.path;
          _fileName = image.name;
        });
      }
    }
  }

  Future<void> _submitProduct() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final description = _descriptionController.text.trim();

    if (name.isEmpty ||
        price == null ||
        description.isEmpty ||
        _imageBytes == null ||
        _fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields including image are required"),
        ),
      );
      return;
    }

    final productJson = jsonEncode({
      "name": name,
      "price": price,
      "description": description,
    });

    try {
      final response = await addProduct(
        productJson,
        _imageBytes!,
        _fileName!,
        _filePath,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully!")),
        );
        if (!context.mounted) return;
        Navigator.pop(context, true); // ✅ This refreshes ProductMaintenancePage
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Exception: $e")));
    }
  }

  Future<http.Response> addProduct(
    String productJson,
    Uint8List imageBytes,
    String fileName,
    String? localPath,
  ) async {
    const String baseUrl =
        'http://192.168.10.157:8080'; // Change to your backend IP
    final uri = Uri.parse('$baseUrl/api/products');

    final request = http.MultipartRequest('POST', uri);
    request.fields['product'] = productJson;

    final mimeType =
        lookupMimeType(fileName, headerBytes: imageBytes) ?? 'image/jpeg';
    final mimeSplit = mimeType.split('/');

    http.MultipartFile imageFile;

    if (kIsWeb) {
      imageFile = http.MultipartFile.fromBytes(
        'photo',
        imageBytes,
        filename: fileName,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      );
    } else {
      imageFile = await http.MultipartFile.fromPath(
        'photo',
        localPath!,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      );
    }

    request.files.add(imageFile);

    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Browse Photo"),
              ),
              const SizedBox(height: 10),
              if (_imageBytes != null)
                Image.memory(
                  _imageBytes!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitProduct,
                child: const Text("Add Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
