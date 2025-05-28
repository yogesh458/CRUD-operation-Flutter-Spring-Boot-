import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'api_config.dart';
import 'product_model.dart';

class ProductService {
  final String baseUrl = ApiConfig.getBaseUrl();

  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  Future<Product> addProduct(String productJson, File photoFile) async {
    final uri = Uri.parse('$baseUrl/api/products');

    var request = http.MultipartRequest('POST', uri);

    request.fields['product'] = productJson;

    final mimeType = lookupMimeType(photoFile.path) ?? 'image/jpeg';
    final mimeSplit = mimeType.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        photoFile.path,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add product');
    }
  }

  Future<bool> updateProduct({
  required int id,
  required String name,
  required double price,
  File? imageFile,
}) async {
  final uri = Uri.parse('${ApiConfig.getBaseUrl()}/$id');

  final request = http.MultipartRequest('PUT', uri)
    ..fields['name'] = name
    ..fields['price'] = price.toString();

  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  }

  final response = await request.send();
  return response.statusCode == 200;
}

}
