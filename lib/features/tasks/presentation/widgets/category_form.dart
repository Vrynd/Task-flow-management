import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../models/task_model.dart';

// ─── Preset Warna Kategori ────────────────────────────────────────────────────

const List<String> _presetColors = [
  '#6366F1', // Indigo
  '#8B5CF6', // Violet
  '#EC4899', // Pink
  '#F43F5E', // Rose
  '#F59E0B', // Amber
  '#10B981', // Emerald
  '#06B6D4', // Cyan
  '#3B82F6', // Blue
];

/// Smart widget untuk membuat kategori baru (nama + pilih warna).
///
/// Menampilkan preview badge secara real-time saat user mengetik nama
/// atau memilih warna.
class CategoryForm extends StatefulWidget {
  final CategoryModel? initialValue;
  final ValueChanged<CategoryModel?> onChanged;

  const CategoryForm({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late final TextEditingController _nameController;
  late String _selectedColor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialValue?.name ?? '');
    _selectedColor = widget.initialValue?.color ?? _presetColors.first;

    _nameController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onChanged() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      widget.onChanged(null);
    } else {
      widget.onChanged(CategoryModel(name: name, color: _selectedColor));
    }
  }

  Color get _currentColor {
    try {
      final hex = _selectedColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.indigo500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasName = _nameController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Toggle Expand ──────────────────────────────────────
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isExpanded
                    ? AppColors.indigo500.withValues(alpha: 0.5)
                    : theme.colorScheme.outline.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.label_outline_rounded,
                  size: 18,
                  color: _isExpanded || hasName
                      ? AppColors.indigo500
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),

                // Preview badge jika nama sudah ada
                if (hasName)
                  _CategoryBadge(
                    name: _nameController.text.trim(),
                    color: _currentColor,
                  )
                else
                  Text(
                    'Tambahkan kategori (opsional)',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                const Spacer(),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),

        // ── Expanded Form ──────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? _ExpandedCategoryForm(
                  nameController: _nameController,
                  selectedColor: _selectedColor,
                  onColorSelected: (color) {
                    setState(() => _selectedColor = color);
                    _onChanged();
                  },
                  presetColors: _presetColors,
                  currentColor: _currentColor,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Expanded Category Form ───────────────────────────────────────────────────

class _ExpandedCategoryForm extends StatelessWidget {
  final TextEditingController nameController;
  final String selectedColor;
  final ValueChanged<String> onColorSelected;
  final List<String> presetColors;
  final Color currentColor;

  const _ExpandedCategoryForm({
    required this.nameController,
    required this.selectedColor,
    required this.onColorSelected,
    required this.presetColors,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Nama Kategori ──────────────────────────────────────
          Text(
            'Nama Kategori',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Contoh: Kuliah, Pekerjaan, Personal...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
            ),
          ),

          const SizedBox(height: 16),

          // ── Pilih Warna ────────────────────────────────────────
          Text(
            'Warna Kategori',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: presetColors.map((hex) {
              final isSelected = hex == selectedColor;
              Color c;
              try {
                c = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
              } catch (_) {
                c = AppColors.indigo500;
              }

              return GestureDetector(
                onTap: () => onColorSelected(hex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 2.5,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: c.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Category Badge ───────────────────────────────────────────────────────────

/// Badge kecil untuk menampilkan kategori dengan warnanya.
class CategoryBadge extends StatelessWidget {
  final String name;
  final Color color;
  final double fontSize;

  const CategoryBadge({
    super.key,
    required this.name,
    required this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) => _CategoryBadge(
        name: name,
        color: color,
        fontSize: fontSize,
      );
}

class _CategoryBadge extends StatelessWidget {
  final String name;
  final Color color;
  final double fontSize;

  const _CategoryBadge({
    required this.name,
    required this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
