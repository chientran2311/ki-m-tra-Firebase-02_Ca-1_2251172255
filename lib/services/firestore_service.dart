import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Singleton Pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;
}