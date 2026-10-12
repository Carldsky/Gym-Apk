import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

const Color profileBackground = Color(0xFF0B0F12);
const Color profileCard = Color(0xFF151B20);
const Color profileGreen = Color(0xFF62E6A2);
const Color profileText = Color(0xFF9AA5AE);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  DateTime? _birthDate;
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  void _initializeForm(ProfileProvider profile) {
    if (_initialized || !profile.isLoaded) return;

    _nameController.text = profile.name;
    _heightController.text = _formatNumber(profile.height);
    _weightController.text = _formatNumber(profile.weight);
    _birthDate = profile.birthDate;

    _initialized = true;
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Pilih tanggal lahir',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: profileGreen,
              onPrimary: profileBackground,
              surface: profileCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _saveProfile(ProfileProvider profile) async {
    if (!_formKey.currentState!.validate()) return;

    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));

    if (height == null || weight == null) return;

    setState(() => _saving = true);

    try {
      await profile.saveProfile(
        newName: _nameController.text,
        newBirthDate: _birthDate,
        newHeight: height,
        newWeight: weight,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan!'),
          backgroundColor: Color(0xFF183D2D),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan profil. Coba lagi.')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, child) {
        _initializeForm(profile);

        if (!profile.isLoaded) {
          return const Scaffold(
            backgroundColor: profileBackground,
            body: Center(child: CircularProgressIndicator(color: profileGreen)),
          );
        }

        return Scaffold(
          backgroundColor: profileBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profil Saya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kelola informasi pribadi kamu',
                      style: TextStyle(color: profileText, fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    // FOTO PROFIL
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 57,
                                backgroundColor: profileCard,
                                backgroundImage:
                                    profile.photoPath != null &&
                                            File(
                                              profile.photoPath!,
                                            ).existsSync()
                                        ? FileImage(File(profile.photoPath!))
                                        : null,
                                child:
                                    profile.photoPath == null ||
                                            !File(
                                              profile.photoPath!,
                                            ).existsSync()
                                        ? const Icon(
                                          Icons.person,
                                          size: 58,
                                          color: profileGreen,
                                        )
                                        : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: profile.pickPhoto,
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: profileGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 20,
                                      color: profileBackground,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: profile.pickPhoto,
                            child: const Text(
                              'Ubah foto profil',
                              style: TextStyle(color: profileGreen),
                            ),
                          ),
                          if (profile.photoPath != null)
                            TextButton(
                              onPressed: profile.removePhoto,
                              child: const Text(
                                'Hapus foto',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // INFORMASI PRIBADI
                    _sectionTitle('Informasi Pribadi'),
                    const SizedBox(height: 14),

                    _label('Nama'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _nameController,
                      hint: 'Masukkan nama kamu',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),
                    _label('Tanggal Lahir'),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: _selectBirthDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 17,
                        ),
                        decoration: BoxDecoration(
                          color: profileCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: profileGreen,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _birthDate == null
                                    ? 'Pilih tanggal lahir'
                                    : '${_birthDate!.day.toString().padLeft(2, '0')}/'
                                        '${_birthDate!.month.toString().padLeft(2, '0')}/'
                                        '${_birthDate!.year}',
                                style: TextStyle(
                                  color:
                                      _birthDate == null
                                          ? profileText
                                          : Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.edit_calendar_outlined,
                              color: profileText,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: profileGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cake_outlined, color: profileGreen),
                          const SizedBox(width: 10),
                          Text(
                            _birthDate == null
                                ? 'Umur akan dihitung otomatis'
                                : 'Umur kamu: ${_calculateAge(_birthDate!)} tahun',
                            style: const TextStyle(
                              color: profileGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // INFORMASI TUBUH
                    _sectionTitle('Informasi Tubuh'),
                    const SizedBox(height: 14),

                    _label('Tinggi Badan (cm)'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _heightController,
                      hint: 'Contoh: 170',
                      icon: Icons.height,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final number = double.tryParse(
                          (value ?? '').replaceAll(',', '.'),
                        );

                        if (number == null || number < 50 || number > 300) {
                          return 'Masukkan tinggi 50–300 cm';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),
                    _label('Berat Badan (kg)'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _weightController,
                      hint: 'Contoh: 70',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final number = double.tryParse(
                          (value ?? '').replaceAll(',', '.'),
                        );

                        if (number == null || number <= 0 || number > 500) {
                          return 'Masukkan berat yang valid';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : () => _saveProfile(profile),
                        icon:
                            _saving
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: profileBackground,
                                  ),
                                )
                                : const Icon(Icons.save_outlined),
                        label: Text(
                          _saving ? 'Menyimpan...' : 'Simpan Profil',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: profileGreen,
                          foregroundColor: profileBackground,
                          disabledBackgroundColor: profileGreen.withValues(
                            alpha: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _calculateAge(DateTime date) {
    final now = DateTime.now();
    var age = now.year - date.year;

    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    return age;
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: profileText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: profileText),
        prefixIcon: Icon(icon, color: profileGreen),
        filled: true,
        fillColor: profileCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: profileGreen),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
