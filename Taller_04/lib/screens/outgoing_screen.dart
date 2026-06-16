import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

/// ─────────────────────────────────────────────────────────────
/// OutgoingScreen — Módulo A: Acciones Salientes
///
/// Panel 1: "Llamador Misterioso" → ACTION_DIAL via url_launcher
/// Panel 2: "Foto Express"        → ACTION_IMAGE_CAPTURE via image_picker
/// ─────────────────────────────────────────────────────────────
class OutgoingScreen extends StatefulWidget {
  const OutgoingScreen({super.key});

  @override
  State<OutgoingScreen> createState() => _OutgoingScreenState();
}

class _OutgoingScreenState extends State<OutgoingScreen> {
  // ── Estado Panel 1: Marcador
  final TextEditingController _phoneController = TextEditingController();
  bool _isDialing = false;

  // ── Estado Panel 2: Cámara
  File? _capturedPhoto;
  bool _isTakingPhoto = false;
  final ImagePicker _picker = ImagePicker();

  // ─────────────────────────────────────────────────────────
  //  PANEL 1 — Intent ACTION_DIAL
  // ─────────────────────────────────────────────────────────

  Future<void> _launchDialer() async {
    final rawNumber = _phoneController.text.trim();

    if (rawNumber.isEmpty) {
      _showSnack('Ingresa un número telefónico primero', isError: true);
      return;
    }

    // Validación básica: solo dígitos, +, espacios y guiones
    final cleaned = rawNumber.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(cleaned)) {
      _showSnack('Número inválido. Ej: 0987654321', isError: true);
      return;
    }

    // Construimos el URI tel: que Android interpreta como ACTION_DIAL
    // url_launcher internamente invoca startActivity(Intent(ACTION_DIAL, Uri.parse("tel:...")))
    final Uri telUri = Uri(scheme: 'tel', path: cleaned);

    setState(() => _isDialing = true);

    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(
          telUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showSnack('No se pudo abrir el marcador', isError: true);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      setState(() => _isDialing = false);
    }
  }

  // ─────────────────────────────────────────────────────────
  //  PANEL 2 — Intent ACTION_IMAGE_CAPTURE
  // ─────────────────────────────────────────────────────────

  Future<void> _takePhoto() async {
    setState(() => _isTakingPhoto = true);

    try {
      // image_picker lanza android.media.action.IMAGE_CAPTURE internamente
      // y espera el ActivityResult — todo manejado por el plugin
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _capturedPhoto = File(photo.path);
        });
        _showSnack('¡Foto capturada!');
      }
    } catch (e) {
      _showSnack('No se pudo acceder a la cámara', isError: true);
    } finally {
      setState(() => _isTakingPhoto = false);
    }
  }

  void _clearPhoto() {
    setState(() => _capturedPhoto = null);
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.send_rounded,
            label: 'MÓDULO',
            title: 'Acciones Salientes',
          ),
          const SizedBox(height: 24),

          // ── Panel 1: Marcador
          _buildDialerPanel(),
          const SizedBox(height: 20),

          // ── Panel 2: Cámara
          _buildCameraPanel(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String label,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFAB6EFF), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: Color(0xFF7C3AED),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF0EEF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Panel 1: Llamador Misterioso
  Widget _buildDialerPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ACTION_DIAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFAB6EFF),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Llamador Misterioso',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF0EEF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Abre el marcador nativo con el número listo para llamar.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B6880)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Color(0xFFF0EEF6)),
                    decoration: const InputDecoration(
                      hintText: 'Ej: 0987654321',
                      prefixIcon: Icon(
                        Icons.phone_rounded,
                        color: Color(0xFF6B6880),
                        size: 20,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isDialing ? null : _launchDialer,
                  icon: _isDialing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.call_rounded, size: 18),
                  label: const Text('Llamar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Panel 2: Foto Express
  Widget _buildCameraPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'IMAGE_CAPTURE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFAB6EFF),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Foto Express',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF0EEF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Abre la cámara nativa y renderiza la miniatura aquí.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B6880)),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contenedor de miniatura
                _buildPhotoContainer(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isTakingPhoto ? null : _takePhoto,
                        icon: _isTakingPhoto
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.camera_alt_rounded, size: 18),
                        label: Text(_isTakingPhoto ? 'Abriendo...' : 'Tomar Foto'),
                      ),
                      if (_capturedPhoto != null) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _clearPhoto,
                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                          label: const Text('Limpiar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6B6880),
                            side: const BorderSide(color: Color(0xFF2A2A35)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoContainer() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _capturedPhoto != null
              ? const Color(0xFF7C3AED)
              : const Color(0xFF2A2A35),
          width: _capturedPhoto != null ? 2 : 1,
        ),
      ),
      child: _capturedPhoto != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(
                _capturedPhoto!,
                fit: BoxFit.cover,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.image_outlined,
                  color: Color(0xFF2A2A35),
                  size: 32,
                ),
                SizedBox(height: 6),
                Text(
                  'Sin foto',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3A3A45),
                  ),
                ),
              ],
            ),
    );
  }
}
