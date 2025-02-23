import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _showProductDialog(
      {String? docId, String? name, String? description, double? price}) {
    _nameController.text = name ?? '';
    _descriptionController.text = description ?? '';
    _priceController.text = price?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Add Product' : 'Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description')),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final description = _descriptionController.text;
                final price = double.tryParse(_priceController.text) ?? 0;

                if (docId == null) {
                  _productService.createProduct(name, description, price);
                } else {
                  _productService.updateProduct(
                      docId, name, description, price);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.teal[300], // สี teal อ่อน
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(8.0), // เพิ่ม padding ให้ ListView
            separatorBuilder: (_, __) => const SizedBox(height: 8), // ระยะห่างระหว่างรายการ
            itemCount: data.length,
            itemBuilder: (context, index) {
              final product = data[index];
              String productId = product.id;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0), // ปรับ margin ของ Card
                elevation: 2, // เพิ่มเงาเล็กน้อย
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 12.0, 12.0), // เพิ่ม padding ด้านซ้าย
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 20.0), // เพิ่ม padding ด้านซ้ายให้ ListTile
                    title: Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4), // ระยะห่างระหว่างชื่อและ description
                        Text(
                          product['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600], // สีจางสำหรับ description
                          ),
                        ),
                        const SizedBox(height: 4), // ระยะห่างระหว่าง description และราคา
                        Text(
                          '${product['price']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green, // สีเขียวเดิมสำหรับราคา
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () {
                            _showProductDialog(
                              docId: productId,
                              name: product['name'],
                              description: product['description'],
                              price: product['price'].toDouble(),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _productService.deleteProduct(productId),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        backgroundColor: Colors.pink[300],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}