import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_app/core/providers/theme_provider.dart';
import 'package:student_management_app/features/finance/providers/finance_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final financeNotifier = ref.watch(financeProvider.notifier);
    final budgetLimit = financeNotifier.budgetLimit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text('Mode Gelap (Dark Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Ubah tampilan aplikasi menjadi gelap.'),
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: theme.colorScheme.primary),
              value: isDark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.account_balance_wallet, color: theme.colorScheme.secondary),
              title: const Text('Batas Anggaran Bulanan', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Saat ini: Rp ${budgetLimit.toStringAsFixed(0)}'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showBudgetDialog(context, ref, budgetLimit),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.info, color: theme.colorScheme.primary),
              title: const Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Collegement v1.0.0'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aplikasi Manajemen Mahasiswa oleh Collegement.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref, double currentLimit) {
    final controller = TextEditingController(text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atur Batas Anggaran'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nominal (Rp)',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text) ?? 0.0;
                ref.read(financeProvider.notifier).setBudgetLimit(val);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
