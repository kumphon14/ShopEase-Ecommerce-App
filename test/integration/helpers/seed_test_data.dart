import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const testCustomerPassword = 'TestPass1!';
const testAdminPassword = 'AdminPass1!';
const testAdminSecretKey = 'SHOPEASE2024';

const seededCategoryId = 'it_category_gadgets';
const seededProductId = 'it_product_phone';
const seededProductName = 'Integration Phone Alpha';
const seededAdminEmail = 'admin.integration@shopease.test';
const seededCustomerEmail = 'customer.integration@shopease.test';
const seededOrderId = 'it_order_pending_001';

class TestUserAccount {
  const TestUserAccount({
    required this.uid,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  final String uid;
  final String email;
  final String password;
  final String name;
  final String role;
}

Future<void> resetIntegrationData() async {
  await FirebaseAuth.instance.signOut();

  await _deleteCollectionGroup('wishlist');

  for (final collection in const [
    'notifications',
    'orders',
    'products',
    'categories',
    'settings',
    'users',
  ]) {
    await _deleteCollection(collection);
  }
}

Future<void> seedBaselineCatalog() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  batch.set(firestore.collection('categories').doc(seededCategoryId), {
    'name': 'Integration Gadgets',
    'imageUrl': 'https://picsum.photos/seed/integration-category/400/400',
  });

  batch.set(firestore.collection('categories').doc('it_category_audio'), {
    'name': 'Integration Audio',
    'imageUrl': 'https://picsum.photos/seed/integration-audio/400/400',
  });

  batch.set(firestore.collection('products').doc(seededProductId), {
    'name': seededProductName,
    'description': 'Seeded product for checkout integration coverage.',
    'price': 199.99,
    'imageUrl': 'https://picsum.photos/seed/integration-phone/400/400',
    'categoryId': seededCategoryId,
    'isFeatured': true,
    'rating': 4.8,
    'admin_rating': 4.8,
  });

  batch.set(firestore.collection('products').doc('it_product_headphones'), {
    'name': 'Integration Headphones Beta',
    'description': 'Secondary seeded product for catalog stability.',
    'price': 89.5,
    'imageUrl': 'https://picsum.photos/seed/integration-headphones/400/400',
    'categoryId': 'it_category_audio',
    'isFeatured': true,
    'rating': 4.4,
    'admin_rating': 4.4,
  });

  batch.set(firestore.collection('settings').doc('company_info'), {
    'bankName': 'Integration Test Bank',
    'accountNumber': '1234567890',
    'accountName': 'ShopEase Integration Tests',
    'promptPayId': '0812345678',
    'qrCodeUrl': null,
  });

  await batch.commit();
}

Future<TestUserAccount> seedAuthUser({
  required String email,
  required String password,
  required String role,
  required String name,
}) async {
  final auth = FirebaseAuth.instance;
  UserCredential credential;

  try {
    credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code != 'email-already-in-use') rethrow;
    credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  final uid = credential.user!.uid;
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'name': name,
    'email': email,
    'role': role,
    'phone': '',
    'address': '',
    'createdAt': FieldValue.serverTimestamp(),
  });

  await auth.signOut();

  return TestUserAccount(
    uid: uid,
    email: email,
    password: password,
    name: name,
    role: role,
  );
}

Future<void> seedPhase1BaseData() async {
  await resetIntegrationData();
  await seedBaselineCatalog();
}

Future<String> seedPendingOrderForCustomer({
  required String customerUid,
  required String customerName,
}) async {
  await FirebaseFirestore.instance.collection('orders').doc(seededOrderId).set({
    'orderId': seededOrderId,
    'items': [
      {
        'id': 'it_cart_item_001',
        'productId': seededProductId,
        'productName': seededProductName,
        'price': 199.99,
        'imageUrl': 'https://picsum.photos/seed/integration-phone/400/400',
        'quantity': 1,
        'rating': 4.8,
      },
    ],
    'totalAmount': 199.99,
    'date': Timestamp.now(),
    'status': 'Order Placed',
    'isNotificationRead': false,
    'isArchived': false,
    'paymentMethod': 'cod',
    'paymentStatus': 'Pending',
    'customerName': customerName,
    'customerId': customerUid,
    'proofOfTransferPath': null,
  });

  return seededOrderId;
}

Future<void> _deleteCollection(String collectionPath) async {
  final collection = FirebaseFirestore.instance.collection(collectionPath);

  while (true) {
    final snapshot = await collection.limit(100).get();
    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

Future<void> _deleteCollectionGroup(String collectionId) async {
  while (true) {
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup(collectionId)
        .limit(100)
        .get();
    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
