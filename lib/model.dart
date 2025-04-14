import 'package:objectbox/objectbox.dart';

@Entity()
class Transaction {
  @Id()
  int id;

  String type;
  double amount;
  DateTime date;

  final category = ToOne<Category>();

  Transaction(this.type, this.amount, this.date, {this.id = 0});
}

@Entity()
class Category {
  @Id()
  int id;

  String name;
  String type;

  Category(this.name, this.type, {this.id = 0});
}

