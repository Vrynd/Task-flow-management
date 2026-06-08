import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/themes/app_colors.dart';

/// Smart widget untuk memilih tanggal deadline.
///
/// Menampilkan tanggal yang dipilih atau placeholder,
/// dan membuka DatePicker saat di-tap.
class DeadlinePicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onChanged;

  const DeadlinePicker({
    super.key,
    this.initialDate,
    required this.onChanged,
  });

  @override
  State<DeadlinePicker> createState() => _DeadlinePickerState();
}

class _DeadlinePickerState extends State<DeadlinePicker> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _pickDate(BuildContext context) async {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.indigo600,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onChanged(picked);
    }
  }

  String get _displayText {
    if (_selectedDate == null) return 'Pilih tanggal deadline';
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate!);
  }

  bool get _hasDate => _selectedDate != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasDate
                ? AppColors.indigo500.withValues(alpha: 0.4)
                : theme.colorScheme.outline.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: _hasDate ? AppColors.indigo500 : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _displayText,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: _hasDate ? FontWeight.w500 : FontWeight.w400,
                  color: _hasDate
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (_hasDate)
              GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = null);
                  widget.onChanged(null);
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
