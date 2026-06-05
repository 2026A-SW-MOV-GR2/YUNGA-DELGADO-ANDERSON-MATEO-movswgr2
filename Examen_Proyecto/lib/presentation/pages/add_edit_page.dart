// lib/presentation/pages/detail/add_edit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/content_item.dart';
import '../providers/content_provider.dart';

class AddEditPage extends StatefulWidget {
  final ContentItem? item;
  const AddEditPage({super.key, this.item});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _title;
  late TextEditingController _year;
  late TextEditingController _genre;
  late TextEditingController _description;
  late TextEditingController _posterUrl;
  late TextEditingController _comment;
  late TextEditingController _season;
  late TextEditingController _episode;

  ContentType _type = ContentType.movie;
  WatchStatus _status = WatchStatus.pending;
  double _rating = 0;
  bool _isFavorite = false;
  DateTime? _watchedDate;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _title = TextEditingController(text: item?.title ?? '');
    _year = TextEditingController(text: item?.year.toString() ?? '');
    _genre = TextEditingController(text: item?.genre ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _posterUrl = TextEditingController(text: item?.posterUrl ?? '');
    _comment = TextEditingController(text: item?.comment ?? '');
    _season = TextEditingController(text: item?.currentSeason?.toString() ?? '');
    _episode = TextEditingController(text: item?.currentEpisode?.toString() ?? '');
    _type = item?.type ?? ContentType.movie;
    _status = item?.status ?? WatchStatus.pending;
    _rating = item?.rating ?? 0;
    _isFavorite = item?.isFavorite ?? false;
    _watchedDate = item?.watchedDate;
  }

  @override
  void dispose() {
    for (final c in [_title, _year, _genre, _description, _posterUrl, _comment, _season, _episode]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar' : 'Agregar'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Guardar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Type selector
            _SectionTitle('Tipo'),
            Row(children: [
              Expanded(child: _TypeBtn(
                label: '🎬 Película',
                selected: _type == ContentType.movie,
                onTap: () => setState(() => _type = ContentType.movie),
              )),
              const SizedBox(width: 12),
              Expanded(child: _TypeBtn(
                label: '📺 Serie',
                selected: _type == ContentType.series,
                onTap: () => setState(() => _type = ContentType.series),
              )),
            ]),
            const SizedBox(height: 20),
            // Basic info
            _SectionTitle('Información'),
            _Field(controller: _title, label: 'Título *', validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Field(
                controller: _year,
                label: 'Año *',
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              )),
              const SizedBox(width: 12),
              Expanded(child: _Field(controller: _genre, label: 'Género')),
            ]),
            const SizedBox(height: 12),
            _Field(controller: _posterUrl, label: 'URL del Póster'),
            const SizedBox(height: 12),
            _Field(controller: _description, label: 'Descripción', maxLines: 3),
            const SizedBox(height: 20),
            // Status
            _SectionTitle('Estado'),
            Wrap(
              spacing: 8,
              children: WatchStatus.values
                  .where((s) => _type == ContentType.movie
                      ? s != WatchStatus.watching
                      : true)
                  .map((s) => ChoiceChip(
                        label: Text(_statusLabel(s)),
                        selected: _status == s,
                        onSelected: (_) => setState(() => _status = s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            // Series fields
            if (_type == ContentType.series) ...[
              _SectionTitle('Progreso de Serie'),
              Row(children: [
                Expanded(child: _Field(
                  controller: _season,
                  label: 'Temporada actual',
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(child: _Field(
                  controller: _episode,
                  label: 'Episodio actual',
                  keyboardType: TextInputType.number,
                )),
              ]),
              const SizedBox(height: 20),
            ],
            // Rating
            _SectionTitle('Calificación Personal'),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 0,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.star),
              onRatingUpdate: (r) => setState(() => _rating = r),
            ),
            const SizedBox(height: 20),
            // Comment
            _SectionTitle('Comentario Personal'),
            _Field(controller: _comment, label: 'Tu opinión...', maxLines: 3),
            const SizedBox(height: 16),
            // Favorite
            SwitchListTile(
              value: _isFavorite,
              onChanged: (v) => setState(() => _isFavorite = v),
              title: const Text('Marcar como favorita', style: TextStyle(color: AppColors.white)),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _statusLabel(WatchStatus s) {
    switch (s) {
      case WatchStatus.pending: return 'Pendiente';
      case WatchStatus.watching: return 'Viendo';
      case WatchStatus.completed: return _type == ContentType.movie ? 'Vista' : 'Completada';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final item = ContentItem(
      id: widget.item?.id ?? const Uuid().v4(),
      title: _title.text.trim(),
      year: int.tryParse(_year.text) ?? now.year,
      genre: _genre.text.trim(),
      description: _description.text.trim(),
      posterUrl: _posterUrl.text.trim(),
      type: _type,
      status: _status,
      watchedDate: _status == WatchStatus.completed
          ? (_watchedDate ?? now)
          : _watchedDate,
      rating: _rating,
      comment: _comment.text.trim(),
      isFavorite: _isFavorite,
      currentSeason: int.tryParse(_season.text),
      currentEpisode: int.tryParse(_episode.text),
    );

    final provider = context.read<ContentProvider>();
    if (_isEditing) {
      await provider.updateItem(item);
    } else {
      await provider.addItem(item);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(
          color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w700)),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.greyDark,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.grey,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
