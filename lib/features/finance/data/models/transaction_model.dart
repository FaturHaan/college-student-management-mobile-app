import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 4)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  bool isIncome;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String category;

  @HiveField(5)
  String note;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.category,
    required this.note,
  });
}
