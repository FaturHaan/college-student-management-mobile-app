import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:student_management_app/features/finance/data/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

const String transactionsBoxName = 'transactionsBox';
const String settingsBoxName = 'settingsBox';
const String budgetLimitKey = 'budgetLimit';

class FinanceNotifier extends StateNotifier<List<TransactionModel>> {
  FinanceNotifier() : super([]) {
    _loadTransactions();
  }

  void _loadTransactions() {
    final box = Hive.box<TransactionModel>(transactionsBoxName);
    final transactions = box.values.toList();
    // Urutkan berdasarkan tanggal terbaru
    transactions.sort((a, b) => b.date.compareTo(a.date));
    state = transactions;
  }

  Future<void> addTransaction({
    required double amount,
    required bool isIncome,
    required DateTime date,
    required String category,
    required String note,
  }) async {
    const uuid = Uuid();
    final newTransaction = TransactionModel(
      id: uuid.v4(),
      amount: amount,
      isIncome: isIncome,
      date: date,
      category: category,
      note: note,
    );

    final box = Hive.box<TransactionModel>(transactionsBoxName);
    await box.put(newTransaction.id, newTransaction);
    
    final updatedList = [...state, newTransaction];
    updatedList.sort((a, b) => b.date.compareTo(a.date));
    state = updatedList;
  }

  Future<void> removeTransaction(String id) async {
    final box = Hive.box<TransactionModel>(transactionsBoxName);
    await box.delete(id);
    state = state.where((t) => t.id != id).toList();
  }

  // --- Analisis Agregat (Getters / Helpers) ---
  
  double get totalBalance {
    return state.fold(0, (sum, t) => t.isIncome ? sum + t.amount : sum - t.amount);
  }

  double get totalIncomeThisMonth {
    final now = DateTime.now();
    return state
        .where((t) => t.isIncome && t.date.year == now.year && t.date.month == now.month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpenseThisMonth {
    final now = DateTime.now();
    return state
        .where((t) => !t.isIncome && t.date.year == now.year && t.date.month == now.month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, double> get expensesByCategory {
    final now = DateTime.now();
    final Map<String, double> map = {};
    for (var t in state) {
      if (!t.isIncome && t.date.year == now.year && t.date.month == now.month) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  String get financialAnalysis {
    final income = totalIncomeThisMonth;
    final expense = totalExpenseThisMonth;

    if (income == 0 && expense == 0) return "Belum ada riwayat keuangan bulan ini.";
    if (income == 0 && expense > 0) return "Anda memiliki pengeluaran tanpa adanya pemasukan bulan ini. Harap berhati-hati dalam menggunakan sisa saldo Anda.";

    final ratio = expense / income;
    
    if (ratio <= 0.40) {
      return "Kondisi keuangan Anda dalam keadaan yang sangat baik. Pertahankan pola pengeluaran ini.";
    } else if (ratio <= 0.70) {
      return "Pengeluaran Anda masih dalam batas wajar. Namun, disarankan untuk mulai memperhatikan alokasi dana.";
    } else if (ratio <= 0.90) {
      return "Pengeluaran Anda cukup tinggi dibanding pemasukan. Sebaiknya evaluasi dan kurangi pos pengeluaran yang tidak prioritas.";
    } else {
      return "Pengeluaran Anda sangat mendekati atau melampaui pemasukan. Diperlukan penghematan segera untuk menjaga stabilitas keuangan.";
    }
  }

  // --- Batas Anggaran (Budget Limit) ---
  double get budgetLimit {
    final box = Hive.box(settingsBoxName);
    return box.get(budgetLimitKey, defaultValue: 0.0);
  }

  Future<void> setBudgetLimit(double limit) async {
    final box = Hive.box(settingsBoxName);
    await box.put(budgetLimitKey, limit);
    // Trigger pembaruan state dengan me-reassign referensi array (agar widget me-rebuild peringatan)
    state = [...state];
  }
}

final financeProvider = StateNotifierProvider<FinanceNotifier, List<TransactionModel>>((ref) {
  return FinanceNotifier();
});
