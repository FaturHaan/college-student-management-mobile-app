import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_app/core/theme/app_colors.dart';
import 'package:student_management_app/features/tasks/providers/task_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String status = 'Belum Dikerjakan';
    int reminderHours = 24;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Tambah Tugas Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Judul Tugas'),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tenggat Waktu'),
                      subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setStateSB(() => selectedDate = date);
                        }
                      },
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: reminderHours,
                      items: const [
                        DropdownMenuItem(value: 72, child: Text('H-3 (72 jam)')),
                        DropdownMenuItem(value: 48, child: Text('H-2 (48 jam)')),
                        DropdownMenuItem(value: 24, child: Text('H-1 (24 jam)')),
                        DropdownMenuItem(value: 12, child: Text('12 jam sebelumnya')),
                        DropdownMenuItem(value: 6, child: Text('6 jam sebelumnya')),
                        DropdownMenuItem(value: 3, child: Text('3 jam sebelumnya')),
                      ],
                      onChanged: (v) => setStateSB(() => reminderHours = v!),
                      decoration: const InputDecoration(labelText: 'Pengingat'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      items: const [
                        DropdownMenuItem(value: 'Belum Dikerjakan', child: Text('Belum Dikerjakan')),
                        DropdownMenuItem(value: 'Sedang Dikerjakan', child: Text('Sedang Dikerjakan')),
                        DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                      ],
                      onChanged: (v) => setStateSB(() => status = v!),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      ref.read(taskProvider.notifier).addTask(
                            titleController.text.trim(),
                            descController.text.trim(),
                            selectedDate,
                            status,
                            reminderHours,
                          );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateStatusDialog(String taskId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Perbarui Status Tugas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.radio_button_unchecked, color: Colors.redAccent),
                title: const Text('Belum Dikerjakan'),
                onTap: () {
                  ref.read(taskProvider.notifier).updateTaskStatus(taskId, 'Belum Dikerjakan');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.autorenew, color: Colors.orange),
                title: const Text('Sedang Dikerjakan'),
                onTap: () {
                  ref.read(taskProvider.notifier).updateTaskStatus(taskId, 'Sedang Dikerjakan');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Selesai'),
                onTap: () {
                  ref.read(taskProvider.notifier).updateTaskStatus(taskId, 'Selesai');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Tugas'),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('Hore! Tidak ada tugas saat ini. 🎉'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                
                Color statusColor;
                if (task.status == 'Selesai') {
                  statusColor = Colors.green;
                } else if (task.status == 'Sedang Dikerjakan') {
                  statusColor = Colors.orange;
                } else {
                  statusColor = Colors.redAccent;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.2),
                      child: Icon(Icons.assignment, color: statusColor),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task.status == 'Selesai' ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      'Tenggat: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year} • ${task.status}',
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.description.isEmpty ? 'Tidak ada deskripsi' : task.description),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showUpdateStatusDialog(task.id, task.status),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Update Status'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => ref.read(taskProvider.notifier).removeTask(task.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
