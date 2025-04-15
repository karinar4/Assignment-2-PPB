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

    Transaction transaction1 = Transaction('Income', 10000000.0, DateTime(2025, 4, 9));
    transaction1.category.target = category1;

    Transaction transaction2 = Transaction('Expense', 50000.0, DateTime(2025, 4, 13));
    transaction2.category.target = category2;

    Transaction transaction3 = Transaction('Income', 200000.0, DateTime(2025, 4, 10));
    transaction3.category.target = category3;

    Transaction transaction4 = Transaction('Expense', 100000.0, DateTime(2025, 4, 12));
    transaction4.category.target = category4;

    transactionBox.putMany([transaction1, transaction2, transaction3, transaction4]);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  void addTransaction(String type, double amount, DateTime date, Category category){
    Transaction newTransaction = Transaction(type, amount, date);
    newTransaction.category.target = category;

    transactionBox.put(newTransaction);
  }

  void updateTransaction(int id, String type, double amount, DateTime date, Category category) {
    final transaction = transactionBox.get(id);
    if (transaction != null) {
      transaction.type = type;
      transaction.amount = amount;
      transaction.date = date;
      transaction.category.target = category;
      transactionBox.put(transaction);
    }
  }

  void deleteTransaction(int id) {
    transactionBox.remove(id);
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

