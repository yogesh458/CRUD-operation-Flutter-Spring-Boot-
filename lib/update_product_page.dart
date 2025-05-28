import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:productapp/product_model.dart';

class UpdateProductScreen extends StatefulWidget {
  final Product product;

  const UpdateProductScreen({super.key, required this.product});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  Uint8List? _imageBytes;
  String? _fileName;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _imageBytes = base64Decode(widget.product.photoBase64);
    _fileName = "existing_image.jpg";
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
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

  // bool _isModified() {
  //   return _nameController.text.trim() != widget.product.name ||
  //       _priceController.text.trim() != widget.product.price.toString() ||
  //       _descriptionController.text.trim() != widget.product.description ||
  //       _imageBytes != base64Decode(widget.product.photoBase64);
  // }

  Future<void> _submitUpdate() async {
  final newName = _nameController.text.trim();
  final newPrice = double.tryParse(_priceController.text.trim());
  final newDesc = _descriptionController.text.trim();

  final original = widget.product;

  // Check if user changed anything
  bool isTextChanged = newName != original.name ||
      newPrice != original.price ||
      newDesc != original.description;

  bool isImageChanged = _imageBytes != null &&
      base64Encode(_imageBytes!) != original.photoBase64;

  if (!isTextChanged && !isImageChanged) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You didn't update anything")),
    );
    return;
  }

  final productJson = jsonEncode({
    "name": newName,
    "price": newPrice,
    "description": newDesc,
  });

  try {
    final uri =
        Uri.parse('http://192.168.10.157:8080/api/products/${original.id}');
    final request = http.MultipartRequest('PUT', uri);
    request.fields['product'] = productJson;

    if (isImageChanged) {
      final mimeType =
          lookupMimeType(_fileName!, headerBytes: _imageBytes!) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');

      http.MultipartFile imageFile;
      if (kIsWeb) {
        imageFile = http.MultipartFile.fromBytes(
          'photo',
          _imageBytes!,
          filename: _fileName!,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        );
      } else {
        imageFile = await http.MultipartFile.fromPath(
          'photo',
          _filePath!,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        );
      }

      request.files.add(imageFile);
    }

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (responseData.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully")),
      );
      if (!context.mounted) return;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: ${responseData.body}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Exception: $e")),
    );
  }
}


  Future<http.Response> updateProductWithPhoto(
    int productId,
    String productJson,
    Uint8List imageBytes,
    String fileName,
    String? localPath,
  ) async {
    const String baseUrl = 'http://192.168.10.157:8080';
    final uri = Uri.parse('$baseUrl/api/products/$productId');

    final request = http.MultipartRequest('PUT', uri);
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
      appBar: AppBar(title: const Text("Update Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
              onPressed: _submitUpdate,
              child: const Text("Update Product"),
            ),
          ],
        ),
      ),
    );
  }
}
