import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';
import 'book_form_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final List<Book> _books = [
    Book(
      id: '1',
      title: 'Cien años de soledad',
      author: 'Gabriel García Márquez',
      genre: 'Realismo Mágico',
      description:
      'La historia de la familia Buendía a lo largo de siete generaciones en el pueblo ficticio de Macondo.',
      publishDate: DateTime(1967, 5, 30),
      isRead: true,
      coverColor: '#8B4513',
    ),
    Book(
      id: '2',
      title: 'El nombre de la rosa',
      author: 'Umberto Eco',
      genre: 'Misterio histórico',
      description:
      'Un monje franciscano investiga una serie de misteriosas muertes en una abadía medieval italiana.',
      publishDate: DateTime(1980, 1, 1),
      isRead: false,
      coverColor: '#2E4057',
    ),
    Book(
      id: '3',
      title: 'Ficciones',
      author: 'Jorge Luis Borges',
      genre: 'Cuentos',
      description:
      'Colección de relatos que exploran laberintos, bibliotecas infinitas y realidades alternativas.',
      publishDate: DateTime(1944, 1, 1),
      isRead: true,
      coverColor: '#1B5E20',
    ),
    Book(
      id: '4',
      title: 'La sombra del viento',
      author: 'Carlos Ruiz Zafón',
      genre: 'Novela gótica',
      description:
      'En la Barcelona de posguerra, un niño descubre un misterioso libro cuyo autor parece querer borrar de la historia.',
      publishDate: DateTime(2001, 1, 1),
      isRead: false,
      coverColor: '#4A148C',
    ),
  ];

  static const _channel = MethodChannel('com.taller04/toast');

  Future<void> _showNativeToast(String message) async {
    try {
      await _channel.invokeMethod('showToast', {'message': message});
    } on PlatformException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _confirmDelete(Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 36),
        title: const Text('Eliminar libro'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${book.title}"?\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _books.removeWhere((b) => b.id == book.id));
              _showNativeToast('Libro eliminado con éxito');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToForm({Book? book}) async {
    final result = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (_) => BookFormScreen(book: book)),
    );
    if (result != null) {
      setState(() {
        if (book == null) {
          _books.add(result);
        } else {
          final idx = _books.indexWhere((b) => b.id == result.id);
          if (idx != -1) _books[idx] = result;
        }
      });
      _showNativeToast(book == null ? 'Libro agregado' : 'Libro actualizado');
    }
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Biblioteca'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _books.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Sin libros aún. ¡Agrega uno!',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _books.length,
        itemBuilder: (ctx, i) => _BookCard(
          book: _books[i],
          coverColor: _hexColor(_books[i].coverColor),
          onTap: () => _navigateToForm(book: _books[i]),
          onLongPress: () => _confirmDelete(_books[i]),
          onDeletePressed: () => _confirmDelete(_books[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar libro'),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final Color coverColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDeletePressed;

  const _BookCard({
    required this.book,
    required this.coverColor,
    required this.onTap,
    required this.onLongPress,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portada simulada
              Container(
                width: 56,
                height: 84,
                decoration: BoxDecoration(
                  color: coverColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: coverColor.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  book.title[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      book.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Autor
                    Text(
                      book.author,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 5),

                    // Descripción ← nuevo
                    if (book.description.isNotEmpty)
                      Text(
                        book.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),

                    // Badge leído / pendiente
                    Row(
                      children: [
                        Icon(
                          book.isRead
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 15,
                          color: book.isRead ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.isRead ? 'Leído' : 'Pendiente',
                          style: TextStyle(
                            fontSize: 12,
                            color: book.isRead ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Eliminar',
                onPressed: onDeletePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}