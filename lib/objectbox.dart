import 'package:flutter/material.dart';

import 'model.dart';
import 'objectbox.g.dart';

class ObjectBox {
  late final Store store;

  late final Box<Transaction> transactionBox;
  late final Box<Category> categoryBox;

  ObjectBox._create(this.store){
    transactionBox = Box<Transaction>(store);
    categoryBox = Box<Category>(store);
    
    if (transactionBox.isEmpty()){
      _putDemoData();
    }
  }

  void _putDemoData(){
    Category category1 = Category('Salary', 'Income');
    Category category2 = Category('Food', 'Expense');
    Category category3 = Category('Gift', 'Income');
    Category category4 = Category('Transport', 'Expense');

    Transaction transaction1 = Transaction('Income', 5000.0, DateTime(2025, 4, 1));
    transaction1.category.target = category1;

    Transaction transaction2 = Transaction('Expense', 10.5, DateTime(2025, 4, 3));
    transaction2.category.target = category2;

    Transaction transaction3 = Transaction('Income', 100.0, DateTime(2025, 4, 2));
    transaction3.category.target = category3;

    Transaction transaction4 = Transaction('Expense', 12.0, DateTime(2025, 4, 5));
    transaction4.category.target = category4;

    transactionBox.putMany([transaction1, transaction2]);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  void addTransaction(String type, double amount, DateTime date, Category category){
    Transaction newTransaction = Transaction(type, amount, date);
    newTransaction.category.target = category;

    transactionBox.put(newTransaction);

    debugPrint("Added Transaction: amount=${newTransaction.amount}, type=${newTransaction.type}, date=${newTransaction.date}, category=${newTransaction.category.target?.name}");
  }

  int addCategory(String type, String name){
    Category categoryToAdd = Category(name, type);
    int newObjectId = categoryBox.put(categoryToAdd);

    return newObjectId;
  }

  Stream<List<Transaction>> getAllTransactions(){
    final builder = transactionBox.query()..order(Transaction_.date, flags: Order.descending);
    return builder.watch(triggerImmediately: true).map((query) => query.find());
  }

  Stream<List<Transaction>> getIncomes(){
    final builder = transactionBox.query(Transaction_.type.equals('Income'))..order(Transaction_.date, flags: Order.descending);
    return builder.watch(triggerImmediately: true).map((query) => query.find());
  }

  Stream<List<Transaction>> getExpenses() {
    final builder = transactionBox.query(Transaction_.type.equals('Expense'))..order(Transaction_.date, flags: Order.descending);
    return builder.watch(triggerImmediately: true).map((query) => query.find());
  }
}

