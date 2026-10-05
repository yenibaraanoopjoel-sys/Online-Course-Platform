import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../core/constants/app_constants.dart';

class CategoryService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  CategoryService() {
    _initStream();
  }

  void _initStream() {
    categoriesStream().listen((cats) {
      _categories = cats;
      notifyListeners();
    });
  }

  CollectionReference get _col => _db.collection(AppConstants.categoriesCol);

  Stream<List<CategoryModel>> categoriesStream() {
    return _col.orderBy('name').snapshots().map((snap) =>
        snap.docs.map((d) => CategoryModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return null;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snap = await _col.orderBy('name').get();
      return snap.docs
          .map((d) => CategoryModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> createCategory(CategoryModel cat) async {
    try {
      final ref = await _col.add(cat.toMap());
      return ref.id;
    } catch (e) {
      debugPrint('CategoryService.createCategory: $e');
      return null;
    }
  }

  Future<bool> updateCategory(CategoryModel cat) async {
    try {
      await _col.doc(cat.categoryId).update(cat.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _col.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getCategoryCount() async {
    try {
      final snap = await _col.count().get();
      return snap.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
