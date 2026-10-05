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

  static final List<CategoryModel> _defaultSampleCategories = [
    CategoryModel(
      categoryId: 'mobile-dev',
      name: 'Mobile Development',
      description: 'Flutter, iOS, Android, and cross-platform apps',
      image: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      categoryId: 'ui-ux',
      name: 'Design & UI/UX',
      description: 'Figma, prototyping, design systems, and wireframing',
      image: 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=400',
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      categoryId: 'cloud-backend',
      name: 'Cloud & Backend',
      description: 'Firebase, Cloud Functions, APIs, and microservices',
      image: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400',
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      categoryId: 'web-dev',
      name: 'Web Development',
      description: 'Frontend frameworks, responsive architecture, and HTML/CSS',
      image: 'https://images.unsplash.com/photo-1547658719-da2b51169166?w=400',
      createdAt: DateTime.now(),
    ),
  ];

  Stream<List<CategoryModel>> categoriesStream() {
    return _col.orderBy('name').snapshots().map((snap) {
      if (snap.docs.isEmpty) return _defaultSampleCategories;
      return snap.docs
          .map((d) => CategoryModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
    });
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) {
        return _defaultSampleCategories.where((c) => c.categoryId == id).firstOrNull;
      }
      return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return _defaultSampleCategories.where((c) => c.categoryId == id).firstOrNull;
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
