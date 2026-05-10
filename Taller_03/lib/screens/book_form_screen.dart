import 'package:flutter/material.dart';
import '../models/book.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;

  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _genreCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _publishDate;
  late bool _isRead;
  late String _coverColor;

  bool get _isEditing => widget.book != null;

  final List<Map<String, String>> _colorOptions = [
    {'label': 'Caoba',        'hex': '#8B4513'},
    {'label': 'Azul noche',   'hex': '#2E4057'},
    {'label': 'Verde bosque', 'hex': '#1B5E20'},
    {'label': 'Púrpura',      'hex': '#4A148C'},
    {'label': 'Rojo oscuro',  'hex': '#B71C1C'},
    {'label': 'Teal',         'hex': '#004D40'},
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl   = TextEditingController(text: b?.title ?? '');
    _authorCtrl  = TextEditingController(text: b?.author ?? '');
    _genreCtrl   = TextEditingController(text: b?.genre ?? '');
    _descCtrl    = TextEditingController(text: b?.description ?? '');
    _publishDate = b?.publishDate ?? DateTime(2000, 1, 1);
    _isRead      = b?.isRead ?? false;
    _coverColor  = b?.coverColor ?? '#8B4513';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _genreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishDate,
      firstDate: DateTime(1000),
      lastDate: DateTime.now(),
      helpText: 'Fecha de publicación',
    );
    if (picked != null) setState(() => _publishDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final book = Book(
      id:          widget.book?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title:       _titleCtrl.text.trim(),
      author:      _authorCtrl.text.trim(),
      genre:       _genreCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      publishDate: _publishDate,
      isRead:      _isRead,
      coverColor:  _coverColor,
    );

    Navigator.of(context).pop(book);
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar libro' : 'Nuevo libro'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vista previa de portada
              Center(
                child: Container(
                  width: 90,
                  height: 130,
                  decoration: BoxDecoration(
                    color: _hexColor(_coverColor),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _hexColor(_coverColor).withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(3, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _titleCtrl.text.isEmpty ? '?' : _titleCtrl.text[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Título
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'El título es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Autor
              TextFormField(
                controller: _authorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Autor *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'El autor es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Género
              TextFormField(
                controller: _genreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Género',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Descripción ← nuevo campo multilínea
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Breve sinopsis o notas personales...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes),
                  ),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),

              // Fecha de publicación
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de publicación',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_publishDate.day}/${_publishDate.month}/${_publishDate.year}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Color de portada
              Text('Color de portada',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _colorOptions.map((c) {
                  final selected = _coverColor == c['hex'];
                  return GestureDetector(
                    onTap: () => setState(() => _coverColor = c['hex']!),
                    child: Tooltip(
                      message: c['label']!,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _hexColor(c['hex']!),
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: Colors.black87, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: selected ? 6 : 2,
                            ),
                          ],
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Switch Leído / Pendiente
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: const Text('¿Ya lo leíste?'),
                  subtitle: Text(
                      _isRead ? 'Marcado como leído ✓' : 'Pendiente de leer'),
                  value: _isRead,
                  onChanged: (v) => setState(() => _isRead = v),
                  secondary: Icon(
                    _isRead ? Icons.check_circle : Icons.hourglass_empty,
                    color: _isRead ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(
                      _isEditing ? 'Guardar cambios' : 'Agregar libro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}