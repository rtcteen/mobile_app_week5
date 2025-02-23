import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  // Read Data
  Stream<QuerySnapshot> getProducts() {
    return products.snapshots();
  }

  // Create Data
  Future<void> createProduct(String name, String description, double price) async {
    await products.add({'name': name, 'description': description, 'price': price});
  }

  // Update Data
  Future<void> updateProduct(String docId, String name, String description, double price) async {
    await products.doc(docId).update({'name': name, 'description': description, 'price': price});
  }

  // Delete Data
  Future<void> deleteProduct(String docId) async {
    await products.doc(docId).delete();
  }
}
