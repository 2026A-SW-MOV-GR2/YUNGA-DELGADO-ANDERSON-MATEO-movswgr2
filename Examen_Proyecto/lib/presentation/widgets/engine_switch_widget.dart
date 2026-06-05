// lib/presentation/widgets/engine_switch_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/content_provider.dart';

/// Switch interactivo en el AppBar para conmutar entre SQL y NoSQL en tiempo real.
class EngineSwitchWidget extends StatelessWidget {
  const EngineSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, provider, _) {
        final isNoSql = provider.isNoSql;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chip indicador de motor activo
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNoSql
                      ? Colors.purple.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isNoSql ? Colors.purple : AppColors.primary,
                    width: 1,
                  ),
                ),
                child: Text(
                  isNoSql ? 'NoSQL' : 'SQL',
                  style: TextStyle(
                    color: isNoSql ? Colors.purple[200] : AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                height: 28,
                child: Switch(
                  value: isNoSql,
                  onChanged: provider.isLoading
                      ? null
                      : (val) => provider.switchEngine(toNoSql: val),
                  activeColor: Colors.purple[400],
                  inactiveThumbColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withOpacity(0.3),
                  activeTrackColor: Colors.purple.withOpacity(0.4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
