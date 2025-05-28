import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const ProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onUpdate,
  });

  Future<Uint8List> _loadImageBytes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return base64Decode(product.photoBase64);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: FutureBuilder<Uint8List>(
                future: _loadImageBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 150,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      width: 150,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.error, size: 40)),
                    );
                  } else {
                    return Image.memory(
                      snapshot.data!,
                      width: 150,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
               child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      product.name,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    const SizedBox(height: 8),
    Text(
      '₹ ${product.price.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
      ),
    ),
    const SizedBox(height: 8),
    Expanded(
      child: SingleChildScrollView(
        child: Text(
          product.description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    ),
    const SizedBox(height: 6),
    Align(
  alignment: Alignment.bottomRight,
  child: Wrap(
    spacing: 8, // spacing between buttons
    runSpacing: 4, // spacing if buttons wrap to next line
    children: [
      ElevatedButton.icon(
        onPressed: onUpdate,
        icon: const Icon(Icons.edit),
        label: const Text("Update"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, 36), // removes default min size
        ),
      ),
      ElevatedButton.icon(
        onPressed: onDelete,
        icon: const Icon(Icons.delete),
        label: const Text("Delete"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, 36),
        ),
      ),
    ],
  ),
),

  ],
),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
