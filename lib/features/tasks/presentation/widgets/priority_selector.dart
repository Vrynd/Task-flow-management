import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/task_model.dart';

/// Smart widget untuk memilih prioritas tugas.
///
/// Mengelola state selected secara internal, tapi melaporkan perubahan
/// ke parent via [onChanged].
class PrioritySelector extends StatefulWidget {
  final TaskPriority initialValue;
  final ValueChanged<TaskPriority> onChanged;

  const PrioritySelector({
    super.key,
    this.initialValue = TaskPriority.medium,
    required this.onChanged,
  });

  @override
  State<PrioritySelector> createState() => _PrioritySelectorState();
}

class _PrioritySelectorState extends State<PrioritySelector> {
  late TaskPriority _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((p) {
        final isSelected = _selected == p;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: p != TaskPriority.low ? 8 : 0,
            ),
            child: _PriorityPill(
              priority: p,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selected = p);
                widget.onChanged(p);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final TaskPriority priority;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityPill({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? priority.color.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? priority.color
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: priority.color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                priority.label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? priority.color
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
