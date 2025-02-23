import 'package:flutter/material.dart';
import 'product_service.dart'; // นำเข้าไฟล์ firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: StreamBuilder<QuerySnapshot>(
        stream: getProductsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final product = data[index];
              String productId = product.id; // ดึงค่า ID ของเอกสาร
              return ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text(product['name']),
                subtitle: Text(product['description']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteProduct(productId); // ลบสินค้าตาม ID
                  },
                ),
                onTap: () {
                  // แก้ไขข้อมูลเมื่อคลิกที่รายการ
                  _showEditDialog(context, productId, product);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // แสดง dialog สำหรับเพิ่มสินค้าใหม่
          _showCreateDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Dialog สำหรับสร้างสินค้ารายการใหม่
  void _showCreateDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Product'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
              TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String name = nameController.text;
                String description = descriptionController.text;
                double price = double.parse(priceController.text);
                createProduct(name, description, price); // เพิ่มสินค้าลง Firestore
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // ปิด dialog
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Dialog สำหรับแก้ไขสินค้ารายการที่เลือก
  void _showEditDialog(BuildContext context, String productId, QueryDocumentSnapshot product) {
    TextEditingController nameController = TextEditingController(text: product['name']);
    TextEditingController descriptionController = TextEditingController(text: product['description']);
    TextEditingController priceController = TextEditingController(text: product['price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
              TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String name = nameController.text;
                String description = descriptionController.text;
                double price = double.parse(priceController.text);
                updateProduct(productId, name, description, price); // อัพเดตข้อมูล
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // ปิด dialog
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
