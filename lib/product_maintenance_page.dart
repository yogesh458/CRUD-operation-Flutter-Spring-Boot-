import 'package:flutter/material.dart';
import 'package:productapp/add_product_page.dart';
import 'package:productapp/product_model.dart' as model;
import 'package:productapp/update_product_page.dart' as updatePage;

import 'product_service.dart';
import 'product_card.dart';

class ProductMaintenancePage extends StatefulWidget {
  const ProductMaintenancePage({super.key});

  @override
  State<ProductMaintenancePage> createState() => _ProductMaintenancePageState();
}

class _ProductMaintenancePageState extends State<ProductMaintenancePage> {
  final ProductService service = ProductService();
  late Future<List<model.Product>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = service.getAllProducts();
  }

  void refreshProducts() {
    print("🔁 Refreshing products...");
    setState(() {
      productsFuture = service.getAllProducts();
    });
  }

  void deleteProduct(int id) async {
    await service.deleteProduct(id);
    refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  toolbarHeight: 70, // Increases the height of AppBar
  leading: Padding(
    padding: const EdgeInsets.all(10.0),
    child: ClipOval(
      child: Image.asset(
        'assets/logo.png',
        width: 90,     // Increase size here
        height: 50,    // Increase size here
        fit: BoxFit.cover,
      ),
    ),
  ),
  title: const Text('Product Maintenance'),
  centerTitle: true,
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 12.0,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 72, 0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
        ),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (added == true) {
            await Future.delayed(const Duration(milliseconds: 1000));
            refreshProducts();
          }
        },
        child: const Text(
          "Add Product",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  ],
),

      body: FutureBuilder<List<model.Product>>(
        future: productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // space for footer
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                onDelete: () => deleteProduct(products[index].id),
                onUpdate: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => updatePage.UpdateProductScreen(product: products[index]),
                    ),
                  );
                  if (updated == true) {
                    refreshProducts();
                  }
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 50,
        alignment: Alignment.center,
        color: Colors.blue.shade50,
        child: const Text(
          '© 2025 MyCompany',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
