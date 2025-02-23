import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference products = FirebaseFirestore.instance.collection('products');

// อ่านข้อมูลทั้งหมด (Stream)
Stream<QuerySnapshot> getProductsStream() {
  return products.snapshots();
}

// สร้างข้อมูลใหม่
Future<void> createProduct(String name, String description, double price) async {
  await products.add({
    'name': name,
    'description': description,
    'price': price,
  });
}

// อัพเดตข้อมูล
Future<void> updateProduct(String docId, String name, String description, double price) async {
  await products.doc(docId).update({
    'name': name,
    'description': description,
    'price': price,
  });
}

// ลบข้อมูล
Future<void> deleteProduct(String docId) async {
  await products.doc(docId).delete();
}
