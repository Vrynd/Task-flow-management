import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:task_management/core/themes/app_colors.dart';
import 'package:task_management/features/tasks/models/task_model.dart';
import 'package:task_management/features/tasks/presentation/widgets/create_task_form.dart';

class CreateTaskScreen extends StatelessWidget {
  final TaskModel? task;

  const CreateTaskScreen({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    final isEdit = task != null;

    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Back Button & Title (Slate 900) ───────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 16,
                20,
                16,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.slate800.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.slate700.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isEdit ? 'Edit Tugas' : 'Buat Tugas Baru',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Body Card: Container Slate 800 dengan Rounded Top ───
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.slate800,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: CreateTaskForm(task: task),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
