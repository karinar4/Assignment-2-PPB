
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