import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:task_management/core/themes/app_colors.dart';
import 'package:task_management/features/auth/providers/auth_provider.dart';
import 'package:task_management/features/tasks/models/task_model.dart';
import 'package:task_management/features/tasks/providers/task_provider.dart';
import 'package:task_management/features/tasks/presentation/widgets/priority_selector.dart';
import 'package:task_management/features/tasks/presentation/widgets/deadline_picker.dart';
import 'package:task_management/features/tasks/presentation/widgets/category_form.dart';

class CreateTaskForm extends StatefulWidget {
  final TaskModel? task;

  const CreateTaskForm({super.key, this.task});

  @override
  State<CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<CreateTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocus = FocusNode();
  final _descFocus = FocusNode();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _deadline;
  CategoryModel? _category;
  TaskStatus _status = TaskStatus.todo;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _priority = widget.task!.priority;
      _deadline = widget.task!.deadline;
      _category = widget.task!.category;
      _status = widget.task!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    final success = widget.task == null
        ? await taskProvider.createTask(
            title: _titleController.text,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            priority: _priority,
            deadline: _deadline,
            category: _category,
            authToken: authProvider.token,
            authProvider: authProvider,
          )
        : await taskProvider.updateTask(
            id: widget.task!.id,
            title: _titleController.text,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            priority: _priority,
            deadline: _deadline,
            category: _category,
            status: _status,
            authToken: authProvider.token,
            authProvider: authProvider,
          );

    if (success && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Error Banner ─────────────────────────────
                    if (taskProvider.errorMessage != null) ...[
                      _ErrorBanner(message: taskProvider.errorMessage!),
                      const SizedBox(height: 16),
                    ],

                    // ── Judul ────────────────────────────────────
                    const _SectionLabel(label: 'Judul Tugas', isRequired: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      focusNode: _titleFocus,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_descFocus),
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Mengerjakan PR Matematika',
                        hintStyle: GoogleFonts.poppins(fontSize: 13),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.edit_outlined, size: 18),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 44,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Judul tugas wajib diisi';
                        }
                        if (v.trim().length < 3) {
                          return 'Judul terlalu pendek';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Deskripsi ────────────────────────────────
                    const _SectionLabel(label: 'Deskripsi'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      focusNode: _descFocus,
                      maxLines: 3,
                      minLines: 2,
                      textInputAction: TextInputAction.newline,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Tambahkan detail atau catatan... (opsional)',
                        hintStyle: GoogleFonts.poppins(fontSize: 13),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: Icon(Icons.notes_rounded, size: 18),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 44,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Prioritas ────────────────────────────────
                    const _SectionLabel(label: 'Prioritas', isRequired: true),
                    const SizedBox(height: 10),
                    PrioritySelector(
                      initialValue: _priority,
                      onChanged: (p) => setState(() => _priority = p),
                    ),

                    if (widget.task != null) ...[
                      const SizedBox(height: 20),
                      const _SectionLabel(
                        label: 'Status Tugas',
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      _StatusSelector(
                        initialValue: _status,
                        onChanged: (s) => setState(() => _status = s),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Deadline ─────────────────────────────────
                    const _SectionLabel(label: 'Deadline'),
                    const SizedBox(height: 8),
                    DeadlinePicker(
                      initialDate: _deadline,
                      onChanged: (date) => setState(() => _deadline = date),
                    ),

                    const SizedBox(height: 20),

                    // ── Kategori ─────────────────────────────────
                    const _SectionLabel(label: 'Kategori'),
                    const SizedBox(height: 8),
                    CategoryForm(
                      initialValue: _category,
                      onChanged: (cat) => setState(() => _category = cat),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom Submit Button (Fixed) ─────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _SubmitBar(
                isLoading: widget.task == null
                    ? taskProvider.isCreating
                    : taskProvider.isUpdating,
                isEdit: widget.task != null,
                onPressed: () => _submit(context),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Status Selector ─────────────────────────────────────────────────────────

class _StatusSelector extends StatelessWidget {
  final TaskStatus initialValue;
  final ValueChanged<TaskStatus> onChanged;

  const _StatusSelector({required this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskStatus.values.map((s) {
        final isSelected = s == initialValue;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        Color activeColor;
        switch (s) {
          case TaskStatus.todo:
            activeColor = AppColors.indigo500;
            break;
          case TaskStatus.inProgress:
            activeColor = AppColors.priorityMedium;
            break;
          case TaskStatus.done:
            activeColor = AppColors.priorityLow;
            break;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onChanged(s),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.1)
                      : (isDark ? AppColors.slate800 : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? activeColor
                        : (isDark ? AppColors.slate700 : AppColors.slate200),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    s.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? activeColor
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Submit Bar ───────────────────────────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  final bool isLoading;
  final bool isEdit;
  final VoidCallback onPressed;

  const _SubmitBar({
    required this.isLoading,
    required this.isEdit,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.indigo600,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.indigo500.withValues(alpha: 0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    key: const ValueKey('label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEdit ? Icons.check_rounded : Icons.add_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEdit ? 'Perbarui Tugas' : 'Simpan Tugas',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _SectionLabel({required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 3),
          Text(
            '*',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.priorityHigh,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.priorityHigh.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.priorityHigh.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.priorityHigh,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.priorityHigh,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
