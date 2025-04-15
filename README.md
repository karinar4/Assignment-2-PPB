
# Flutter Finance Tracker App

This app uses ObjectBox as a local database solution for storing financial transactions and categories efficiently.

## Setting Up

### 1. Add Dependencies

Add to `pubspec.yaml`:

```
dependencies:

  objectbox: ^4.1.0
  objectbox_flutter_libs: any

dev_dependencies:
  build_runner: ^2.4.15
  objectbox_generator: any
```

After adding these dependencies, run:

```bash
flutter pub get
```

### 2. ObjectBox Files

run this command to generate the ObjectBox files:
```bash
dart run build_runner build
```

## Model Definitions
Define models using @Entity():
```
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
```

## Create a Store
```
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

    transactionBox.putMany([transaction1, transaction2]);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }
```
This class handles the setup and management of the ObjectBox database. It includes the configuration of Box instances for your data models and inserts sample data when the database is initialized for the first time.

## CRUD
The following section explains how the ObjectBox helper class enables CRUD operations.

### Create
Add single transaction
```
final newCategory = Category('Bonus', 'Income');
objectBox.categoryBox.put(newCategory);

final newTransaction = Transaction('Income', 150000.0, DateTime.now());
newTransaction.category.target = newCategory;

objectBox.transactionBox.put(newTransaction);
```
Add multiple transaction
```
objectBox.transactionBox.putMany([transaction1, transaction2]);
```

### Read
Get all
```
List<Transaction> allTransactions = objectBox.transactionBox.getAll();
```
Filter
```
final expenses = objectBox.transactionBox
  .query(Transaction_.type.equals('Expense'))
  .build()
  .find();
```

### Update
```
Transaction? tx = objectBox.transactionBox.get(1);
if (tx != null) {
  tx.amount = 75000.0;
  objectBox.transactionBox.put(tx);
}
```

### Delete
Delete by ID
```
objectBox.categoryBox.remove(category.id);
```
Delete all
```
objectBox.transactionBox.removeAll();
```