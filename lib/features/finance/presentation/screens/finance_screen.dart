import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_management_app/features/finance/providers/finance_provider.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(financeProvider);
    final notifier = ref.watch(financeProvider.notifier);
    final theme = Theme.of(context);

    final expensesByCategory = notifier.expensesByCategory;
    final totalExpense = notifier.totalExpenseThisMonth;
    final budgetLimit = notifier.budgetLimit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Kas Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Ringkasan Keuangan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(context, 'Total Saldo', notifier.totalBalance, Colors.blue),
                    _buildSummaryCard(context, 'Pengeluaran', totalExpense, Colors.red),
                  ],
                ),
                if (budgetLimit > 0 && totalExpense > budgetLimit)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Peringatan: Pengeluaran bulan ini melebihi batas anggaran (Rp ${budgetLimit.toStringAsFixed(0)})!',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Pie Chart
          if (expensesByCategory.isNotEmpty)
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50, // Perbesar center sedikit agar tidak sempit
                      sections: _generatePieSections(expensesByCategory, theme),
                    ),
                  ),
                  const Text('Kategori\nPengeluaran', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          if (expensesByCategory.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Belum ada data pengeluaran bulan ini.', style: TextStyle(color: Colors.grey)),
            ),

          // Analisis Keuangan
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.insights, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notifier.financialAnalysis,
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Riwayat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          
          // Daftar Transaksi
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('Belum ada transaksi.'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      return Dismissible(
                        key: Key(t.id),
                        background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          notifier.removeTransaction(t.id);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: t.isIncome ? Colors.green.shade100 : Colors.red.shade100,
                            child: Icon(
                              t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              color: t.isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(t.note, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${t.category} • ${t.date.day}/${t.date.month}/${t.date.year}'),
                          trailing: Text(
                            '${t.isIncome ? '+' : '-'} Rp ${t.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: t.isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, double amount, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Rp ${amount.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, double> data, ThemeData theme) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal
    ];
    int colorIndex = 0;
    
    return data.entries.map((e) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: e.key, // Hanya tampilkan kategori agar tidak berdesakan
        radius: 45,
        titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    bool isIncome = false;
    String selectedCategory = 'Makanan';
    final categories = ['Makanan', 'Transportasi', 'Tugas/Kuliah', 'Hiburan', 'Lainnya'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tambah Transaksi Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Pengeluaran', style: TextStyle(fontSize: 13)),
                        icon: Icon(Icons.arrow_upward, size: 16),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Pemasukan', style: TextStyle(fontSize: 13)),
                        icon: Icon(Icons.arrow_downward, size: 16),
                      ),
                    ],
                    selected: {isIncome},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() => isIncome = newSelection.first);
                    },
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nominal (Rp)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  if (!isIncome)
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => selectedCategory = val!),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Catatan', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        if (amount > 0) {
                          ref.read(financeProvider.notifier).addTransaction(
                            amount: amount,
                            isIncome: isIncome,
                            date: DateTime.now(),
                            category: isIncome ? 'Pemasukan' : selectedCategory,
                            note: noteController.text.isEmpty ? (isIncome ? 'Pemasukan' : selectedCategory) : noteController.text,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                      child: const Text('Simpan Transaksi'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
