import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  
  // Zorunlu alanlar
  final _nameController = TextEditingController();
  final _salePriceController = TextEditingController();
  
  // Opsiyonel alanlar
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedCategory;
  List<File> _selectedImages = [];
  bool _isLoading = false;

  final _picker = ImagePicker();

  Future<void> _pickImages() async {
    // En fazla 10 fotoğraf kuralı
    if (_selectedImages.length >= 10) {
      CustomSnackbar.show(context, message: 'En fazla 10 fotoğraf yükleyebilirsiniz.', isError: true);
      return;
    }

    final pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var file in pickedFiles) {
          if (_selectedImages.length < 10) {
            _selectedImages.add(File(file.path));
          }
        }
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Fotoğraf zorunluluğu
    if (_selectedImages.isEmpty) {
      CustomSnackbar.show(context, message: 'Lütfen en az 1 ürün fotoğrafı ekleyin.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      List<String> photoUrls = [];

      // 1. Fotoğrafları Storage'a Yükle
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        final fileName = 'products/$userId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        await _supabase.storage.from('product_photos').upload(fileName, file);
        final publicUrl = _supabase.storage.from('product_photos').getPublicUrl(fileName);
        photoUrls.add(publicUrl);
      }

      // 2. Veritabanına Kayıt At
      await _supabase.from('products').insert({
        'user_id': userId,
        'name': _nameController.text.trim(),
        'sale_price': double.parse(_salePriceController.text.replaceAll(',', '.')),
        'production_cost': _costPriceController.text.isNotEmpty ? double.parse(_costPriceController.text.replaceAll(',', '.')) : null,
        'stock_quantity': _stockController.text.isNotEmpty ? int.parse(_stockController.text) : 0,
        'weight': _weightController.text.isNotEmpty ? double.parse(_weightController.text.replaceAll(',', '.')) : null,
        'length': _lengthController.text.isNotEmpty ? double.parse(_lengthController.text.replaceAll(',', '.')) : null,
        'description': _descriptionController.text.trim(),
        'notes': _notesController.text.trim(),
        'category': _selectedCategory,
        'photos': photoUrls,
      });

      if (!mounted) return;
      CustomSnackbar.show(context, message: 'Ürün başarıyla eklendi!', isError: false);
      Navigator.pop(context, true); // true döndürerek önceki sayfanın yenilenmesini tetikliyoruz

    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, message: 'Ürün eklenirken hata oluştu: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Ürün Ekle', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoSection(colorScheme),
                  const SizedBox(height: 24),
                  _buildBasicInfoSection(colorScheme),
                  const SizedBox(height: 24),
                  _buildOptionalInfoSection(colorScheme),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveProduct,
                      icon: const Icon(Icons.save),
                      label: const Text('Ürünü Kaydet'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildPhotoSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fotoğraflar (${_selectedImages.length}/10) *', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary, style: BorderStyle.solid),
                  ),
                  child: Icon(Icons.add_a_photo, color: colorScheme.primary, size: 32),
                ),
              ),
              ..._selectedImages.asMap().entries.map((entry) {
                int idx = entry.key;
                File file = entry.value;
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImages.removeAt(idx)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temel Bilgiler', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Ürün Adı *', filled: true),
          validator: (v) => v == null || v.isEmpty ? 'Ürün adı zorunludur' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _salePriceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Satış Fiyatı (₺) *', filled: true, prefixText: '₺ '),
          validator: (v) => v == null || v.isEmpty ? 'Satış fiyatı zorunludur' : null,
        ),
      ],
    );
  }

  Widget _buildOptionalInfoSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detaylar (İsteğe Bağlı)', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Kategori', filled: true),
          value: _selectedCategory,
          items: ['Elektronik', 'Giyim & Aksesuar', 'Kırtasiye', 'Diğer']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _costPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Maliyet (₺)', filled: true))),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _stockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok Adedi', filled: true))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ağırlık (kg)', filled: true))),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _lengthController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Uzunluk (cm)', filled: true))),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Ürün Açıklaması', filled: true),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Dahili Notlar', filled: true),
        ),
      ],
    );
  }
}