import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _nameKey = 'profile_name';
  static const String _birthDateKey = 'profile_birth_date';
  static const String _heightKey = 'profile_height';
  static const String _weightKey = 'profile_weight';
  static const String _photoKey = 'profile_photo';

  String name = '';
  DateTime? birthDate;
  double height = 170;
  double weight = 70;
  String? photoPath;
  bool isLoaded = false;

  ProfileProvider() {
    loadProfile();
  }

  int? get age {
    if (birthDate == null) return null;

    final now = DateTime.now();
    int result = now.year - birthDate!.year;

    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      result--;
    }

    return result;
  }

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      name = prefs.getString(_nameKey) ?? '';
      height = prefs.getDouble(_heightKey) ?? 170;
      weight = prefs.getDouble(_weightKey) ?? 70;
      photoPath = prefs.getString(_photoKey);

      final savedBirthDate = prefs.getString(_birthDateKey);
      if (savedBirthDate != null) {
        birthDate = DateTime.tryParse(savedBirthDate);
      }
    } catch (e) {
      debugPrint('Gagal memuat profil: $e');
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> saveProfile({
    required String newName,
    required DateTime? newBirthDate,
    required double newHeight,
    required double newWeight,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    name = newName.trim();
    birthDate = newBirthDate;
    height = newHeight;
    weight = newWeight;

    await prefs.setString(_nameKey, name);
    await prefs.setDouble(_heightKey, height);
    await prefs.setDouble(_weightKey, weight);

    if (birthDate != null) {
      await prefs.setString(_birthDateKey, birthDate!.toIso8601String());
    } else {
      await prefs.remove(_birthDateKey);
    }

    notifyListeners();
  }

  Future<void> pickPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (pickedFile == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final extension =
          pickedFile.path.contains('.')
              ? pickedFile.path.split('.').last
              : 'jpg';

      final destination = File('${directory.path}/profile_photo.$extension');

      await File(pickedFile.path).copy(destination.path);

      photoPath = destination.path;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_photoKey, photoPath!);

      notifyListeners();
    } catch (e) {
      debugPrint('Gagal memilih foto: $e');
    }
  }

  Future<void> removePhoto() async {
    try {
      if (photoPath != null) {
        final file = File(photoPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      photoPath = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_photoKey);

      notifyListeners();
    } catch (e) {
      debugPrint('Gagal menghapus foto: $e');
    }
  }
}
